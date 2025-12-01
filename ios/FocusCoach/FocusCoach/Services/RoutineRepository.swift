//
//  RoutineRepository.swift
//  FocusCoach
//
//  Central Routine Repository - Single Source of Truth für Routinen
//

import Foundation
import Combine
import FirebaseFirestore

/// Zentrale Routine-Verwaltung mit Real-time Sync
@MainActor
class RoutineRepository: ObservableObject {
    // Backward compatibility: Singleton bleibt für Migration
    static let shared: RoutineRepository = {
        let repo = RoutineRepository(
            firebaseService: FirebaseService.shared,
            taskRepository: TaskRepository.shared
        )
        // Start listening if authenticated
        if FirebaseService.shared.isAuthenticated {
            repo.startListening()
        }
        return repo
    }()
    
    @Published var allRoutines: [Routine] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firebaseService: FirebaseService
    private let taskRepository: TaskRepository
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    // Neue Initialisierung mit Dependency Injection
    init(firebaseService: FirebaseService, taskRepository: TaskRepository) {
        self.firebaseService = firebaseService
        self.taskRepository = taskRepository
        
        // Start listening when authenticated
        firebaseService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.startListening()
                } else {
                    self?.stopListening()
                }
            }
            .store(in: &cancellables)
        
        // Start if already authenticated
        if firebaseService.isAuthenticated {
            startListening()
        }
    }
    
    // MARK: - Real-time Sync
    
    /// Startet Real-time Synchronisation
    func startListening() {
        guard listener == nil else { 
            print("⚠️ RoutineRepository: Already listening, skipping")
            return 
        }
        
        listener = firebaseService.subscribeToRoutines(completion: { [weak self] routines in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Prüfe ob sich Routinen geändert haben
                let oldRoutineIds = Set(self.allRoutines.map { $0.id })
                let newRoutineIds = Set(routines.map { $0.id })
                
                self.allRoutines = routines
                self.isLoading = false
                print("✅ RoutineRepository: \(routines.count) Routinen geladen")
                
                // NUR wenn neue Routinen hinzugefügt wurden, erstelle Tasks
                // NICHT bei jedem Update (verhindert Infinite Loop)
                if !oldRoutineIds.isEmpty && newRoutineIds != oldRoutineIds {
                    // Neue Routinen wurden hinzugefügt - erstelle Tasks nur für diese
                    let newRoutines = routines.filter { !oldRoutineIds.contains($0.id) && $0.isActive }
                    if !newRoutines.isEmpty {
                        print("🔄 RoutineRepository: Neue Routinen erkannt, erstelle Tasks...")
                        for routine in newRoutines {
                            _Concurrency.Task.detached(priority: .background) {
                                do {
                                    try await self.createTasksFromRoutine(routine)
                                } catch {
                                    print("⚠️ Fehler beim Erstellen von Tasks aus Routine '\(routine.name)': \(error)")
                                }
                            }
                        }
                    }
                } else if oldRoutineIds.isEmpty && !routines.isEmpty {
                    // Erster Load - erstelle Tasks für alle aktiven Routinen
                    print("🔄 RoutineRepository: Erster Load, erstelle Tasks für aktive Routinen...")
                    let activeRoutines = routines.filter { $0.isActive }
                    for routine in activeRoutines {
                        _Concurrency.Task.detached(priority: .background) {
                            do {
                                try await self.createTasksFromRoutine(routine)
                            } catch {
                                print("⚠️ Fehler beim Erstellen von Tasks aus Routine '\(routine.name)': \(error)")
                            }
                        }
                    }
                }
            }
        })
        
        print("✅ RoutineRepository: Started listening to routines")
    }
    
    /// Stoppt Real-time Synchronisation
    func stopListening() {
        listener?.remove()
        listener = nil
        allRoutines = []
        print("🛑 RoutineRepository: Stopped listening to routines")
    }
    
    // MARK: - Routine Operations
    
    /// Speichert eine Routine
    func saveRoutine(_ routine: Routine) async throws {
        isLoading = true
        error = nil
        
        do {
            try await firebaseService.saveRoutine(routine)
            print("✅ RoutineRepository: Routine saved: \(routine.name)")
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    /// Erstellt Tasks aus einer Routine (öffentlich für asynchronen Aufruf)
    func createTasksFromRoutine(_ routine: Routine) async throws {
        guard routine.isActive else { return }
        
        print("🔄 RoutineRepository: Erstelle Tasks aus Routine '\(routine.name)'")
        
        // Erstelle für jeden Task in der Routine einen wiederkehrenden Task
        for routineTask in routine.tasks {
            let task = Task(
                id: UUID().uuidString,
                title: routineTask.title,
                completed: false,
                createdAt: Int64(Date().timeIntervalSince1970 * 1000),
                scheduledDate: nil, // Wird basierend auf repeatPattern gesetzt
                scheduledStartTime: routineTask.startTime,
                scheduledEndTime: routineTask.endTime,
                repeatPattern: routine.repeatPattern,
                repeatWeekdays: routine.repeatWeekdays,
                notes: routineTask.notes,
                blockListId: nil,
                routineId: routine.id // Verknüpfe Task mit Routine
            )
            
            // Prüfe ob bereits ein Task mit diesem Titel und Pattern existiert
            let existingTasks = taskRepository.allTasks.filter { 
                $0.title == task.title && 
                $0.repeatPattern == task.repeatPattern &&
                $0.scheduledStartTime == task.scheduledStartTime
            }
            
            if existingTasks.isEmpty {
                // Speichere Task direkt über FirebaseService (TaskRepeater wird automatisch wiederkehrende Tasks erstellen)
                try await firebaseService.saveTask(task)
                print("✅ RoutineRepository: Task '\(task.title)' aus Routine erstellt")
                
                // Erstelle wiederkehrende Tasks asynchron im Hintergrund
                _Concurrency.Task.detached(priority: .background) {
                    do {
                        try await TaskRepeater.shared.createRepeatingTasks(from: task, daysAhead: 30)
                    } catch {
                        print("⚠️ Fehler beim Erstellen wiederkehrender Tasks: \(error)")
                    }
                }
            } else {
                print("ℹ️ RoutineRepository: Task '\(task.title)' existiert bereits - überspringe")
            }
        }
    }
    
    /// Aktualisiert eine Routine
    func updateRoutine(_ routine: Routine) async throws {
        // WICHTIG: Lösche ALLE Tasks dieser Routine (inklusive Template-Tasks)
        // Das muss VOR dem Speichern passieren, damit keine Race Conditions entstehen
        await deleteTasksForRoutine(routineId: routine.id)
        
        // Warte auf Abschluss ALLER Löschungen (statt fester Wartezeit)
        // Prüfe alle 100ms, ob noch Tasks mit dieser routineId existieren
        var maxWaitAttempts = 50 // Maximal 5 Sekunden warten
        var waitAttempt = 0
        
        while waitAttempt < maxWaitAttempts {
            let remainingTasks = taskRepository.allTasks.filter { task in
                if let taskRoutineId = task.routineId {
                    return taskRoutineId == routine.id
                }
                return false
            }
            
            if remainingTasks.isEmpty {
                print("✅ RoutineRepository: Alle Tasks gelöscht nach \(waitAttempt * 100)ms")
                break
            }
            
            try await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunden
            waitAttempt += 1
        }
        
        if waitAttempt >= maxWaitAttempts {
            print("⚠️ RoutineRepository: Timeout beim Warten auf Task-Löschung")
        }
        
        // Speichere die aktualisierte Routine
        try await saveRoutine(routine)
        
        // Erstelle neue Tasks aus der aktualisierten Routine
        // Dies erstellt sowohl Template-Tasks als auch wiederkehrende Instanzen
        try await createTasksFromRoutine(routine)
    }
    
    /// Löscht alle Tasks einer Routine (inklusive Template-Tasks und wiederkehrende Instanzen)
    private func deleteTasksForRoutine(routineId: String) async {
        // Hole alle Tasks mit dieser routineId (sowohl Template als auch Instanzen)
        let allTasks = taskRepository.allTasks
        let tasksToDelete = allTasks.filter { task in
            if let taskRoutineId = task.routineId {
                return taskRoutineId == routineId
            }
            return false
        }
        
        // Trenne Template-Tasks (mit repeatPattern) und Instanzen (ohne repeatPattern)
        let templateTasks = tasksToDelete.filter { $0.repeatPattern != nil }
        let instanceTasks = tasksToDelete.filter { $0.repeatPattern == nil }
        
        print("🗑️ RoutineRepository: Lösche Tasks für Routine '\(routineId)'")
        print("   - Gesamt Tasks: \(allTasks.count)")
        print("   - Tasks mit routineId: \(allTasks.filter { $0.routineId != nil }.count)")
        print("   - Tasks mit dieser routineId: \(tasksToDelete.count)")
        print("   - Template-Tasks: \(templateTasks.count)")
        print("   - Instanz-Tasks: \(instanceTasks.count)")
        
        // Lösche zuerst Template-Tasks, dann Instanzen
        let allTasksToDelete = templateTasks + instanceTasks
        
        // Lösche alle Tasks sequenziell (nicht parallel, um Race Conditions zu vermeiden)
        for task in allTasksToDelete {
            do {
                try await taskRepository.deleteTask(task.id)
                let taskType = task.repeatPattern != nil ? "Template" : "Instanz"
                print("✅ RoutineRepository: \(taskType)-Task '\(task.title)' gelöscht")
            } catch {
                print("⚠️ RoutineRepository: Fehler beim Löschen von Task '\(task.title)': \(error)")
            }
        }
        
        print("✅ RoutineRepository: Alle Tasks für Routine '\(routineId)' gelöscht")
    }
    
    /// Löscht eine Routine
    func deleteRoutine(_ routineId: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await firebaseService.deleteRoutine(routineId)
            print("✅ RoutineRepository: Routine deleted: \(routineId)")
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Task Creation from Routines
    
    /// Erstellt Tasks aus allen aktiven Routinen (nur manuell aufrufen, nicht automatisch)
    func createTasksFromAllActiveRoutines() {
        let activeRoutines = allRoutines.filter { $0.isActive }
        
        for routine in activeRoutines {
            _Concurrency.Task.detached(priority: .background) {
                do {
                    try await self.createTasksFromRoutine(routine)
                } catch {
                    print("⚠️ Fehler beim Erstellen von Tasks aus Routine '\(routine.name)': \(error)")
                }
            }
        }
    }
    
}

