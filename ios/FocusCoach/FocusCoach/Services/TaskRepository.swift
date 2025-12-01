//
//  TaskRepository.swift
//  FocusCoach
//
//  Central Task Repository - Single Source of Truth
//

import Foundation
import Combine
import FirebaseFirestore

/// Zentrale Task-Verwaltung mit Real-time Sync
@MainActor
class TaskRepository: ObservableObject {
    static let shared = TaskRepository()
    
    @Published var allTasks: [Task] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firebaseService = FirebaseService.shared
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Start listening when authenticated
        firebaseService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.startListening()
                    // Prüfe wiederkehrende Tasks beim Login
                    _Concurrency.Task {
                        await TaskRepeater.shared.checkAndCreateRepeatingTasks()
                    }
                } else {
                    self?.stopListening()
                }
            }
            .store(in: &cancellables)
        
        // Start if already authenticated
        if firebaseService.isAuthenticated {
            startListening()
            // Prüfe wiederkehrende Tasks beim Start
            _Concurrency.Task {
                await TaskRepeater.shared.checkAndCreateRepeatingTasks()
            }
        }
    }
    
    // MARK: - Real-time Sync
    
    /// Startet Real-time Synchronisation
    func startListening() {
        guard listener == nil else { 
            print("⚠️ TaskRepository: Already listening, skipping")
            return 
        }
        
        isLoading = true
        
        listener = firebaseService.subscribeToTasks(completion: { [weak self] tasks in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.allTasks = tasks
                self.isLoading = false
                print("✅ TaskRepository: \(tasks.count) Tasks geladen")
            }
        })
        
        print("✅ TaskRepository: Started listening to tasks")
    }
    
    /// Stoppt Real-time Synchronisation
    func stopListening() {
        listener?.remove()
        listener = nil
        allTasks = []
        print("🛑 TaskRepository: Stopped listening to tasks")
    }
    
    // MARK: - Task Operations
    
    /// Speichert eine Task
    func saveTask(_ task: Task) async throws {
        isLoading = true
        error = nil
        
        do {
            try await firebaseService.saveTask(task)
            // Real-time listener wird automatisch aktualisiert
            print("✅ TaskRepository: Task saved: \(task.title)")
            
            // Wenn Task Wiederholungsmuster hat, erstelle wiederkehrende Tasks
            if task.repeatPattern != nil {
                _Concurrency.Task {
                    do {
                        try await TaskRepeater.shared.createRepeatingTasks(from: task, daysAhead: 30)
                        print("✅ TaskRepository: Wiederkehrende Tasks erstellt für '\(task.title)'")
                    } catch {
                        print("⚠️ TaskRepository: Fehler beim Erstellen wiederkehrender Tasks: \(error)")
                    }
                }
            }
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    /// Aktualisiert eine Task
    func updateTask(_ task: Task) async throws {
        try await saveTask(task)
    }
    
    /// Löscht eine Task
    func deleteTask(_ taskId: String) async throws {
        isLoading = true
        error = nil
        
        do {
            try await firebaseService.deleteTask(taskId)
            // Real-time listener wird automatisch aktualisiert
            print("✅ TaskRepository: Task deleted: \(taskId)")
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    /// Markiert Task als erledigt/nicht erledigt
    func toggleTaskCompletion(_ task: Task) async throws {
        var updatedTask = task
        updatedTask.completed.toggle()
        updatedTask.status = updatedTask.completed ? .completed : .pending
        
        try await updateTask(updatedTask)
    }
    
    // MARK: - Query Methods
    
    /// Gibt Tasks für ein bestimmtes Datum zurück
    func getTasksForDate(_ date: Date) -> [Task] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
        
        return allTasks.filter { task in
            // Tasks ohne Datum gehören zu heute
            if task.scheduledDate == nil {
                return isToday
            }
            return task.scheduledDate == dateString
        }
    }
    
    /// Gibt Tasks für heute zurück
    func getTasksForToday() -> [Task] {
        return getTasksForDate(Date())
    }
    
    /// Gibt Tasks für die aktuelle Woche zurück
    func getTasksForWeek(containing date: Date) -> [Task] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let weekDateStrings = weekDates.map { formatter.string(from: $0) }
        
        return allTasks.filter { task in
            guard let scheduledDate = task.scheduledDate else {
                // Tasks ohne Datum gehören zu heute
                return Calendar.current.isDate(date, inSameDayAs: Date())
            }
            return weekDateStrings.contains(scheduledDate)
        }
    }
    
    /// Gibt alle nicht erledigten Tasks zurück
    func getPendingTasks() -> [Task] {
        return allTasks.filter { !$0.completed }
    }
    
    /// Gibt alle erledigten Tasks zurück
    func getCompletedTasks() -> [Task] {
        return allTasks.filter { $0.completed }
    }
    
    /// Gibt Tasks mit Zeit-Slot zurück
    func getTasksWithTimeSlot(for date: Date) -> [Task] {
        return getTasksForDate(date).filter { $0.hasTimeSlot && !$0.completed }
    }
    
    /// Gibt Tasks ohne Zeit-Slot zurück
    func getTasksWithoutTimeSlot(for date: Date) -> [Task] {
        return getTasksForDate(date).filter { !$0.hasTimeSlot && !$0.completed }
    }
    
    // MARK: - Hierarchie & Block-System
    
    /// Gibt Top-Level Tasks zurück (ohne parentTaskId)
    func getTopLevelTasks(for date: Date) -> [Task] {
        return getTasksForDate(date).filter { $0.parentTaskId == nil }
            .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }
    
    /// Gibt Sub-Tasks für einen Parent-Task zurück
    func getSubTasks(for taskId: String) -> [Task] {
        return allTasks.filter { $0.parentTaskId == taskId }
            .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }
    
    /// Fügt einen Sub-Task zu einem Parent-Task hinzu
    func addSubTask(to parentId: String, task: Task) async throws {
        // Prüfe ob Parent-Task existiert
        guard let parentTask = allTasks.first(where: { $0.id == parentId }) else {
            throw NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Parent-Task nicht gefunden"])
        }
        
        // Erstelle neue Task mit parentTaskId
        var newSubTask = task
        newSubTask.parentTaskId = parentId
        
        // Setze order basierend auf Anzahl der Sub-Tasks
        let existingSubTasks = getSubTasks(for: parentId)
        newSubTask.order = existingSubTasks.count
        
        // Speichere Sub-Task
        try await saveTask(newSubTask)
        
        // Aktualisiere Parent-Task: Füge Sub-Task ID zu subTaskIds hinzu
        var updatedParent = parentTask
        var subTaskIds = updatedParent.subTaskIds ?? []
        if !subTaskIds.contains(newSubTask.id) {
            subTaskIds.append(newSubTask.id)
            updatedParent.subTaskIds = subTaskIds
            try await updateTask(updatedParent)
        }
        
        print("✅ TaskRepository: Sub-Task '\(newSubTask.title)' zu '\(parentTask.title)' hinzugefügt")
    }
    
    /// Entfernt einen Sub-Task von einem Parent-Task
    func removeSubTask(from parentId: String, taskId: String) async throws {
        // Prüfe ob Parent-Task existiert
        guard let parentTask = allTasks.first(where: { $0.id == parentId }) else {
            throw NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Parent-Task nicht gefunden"])
        }
        
        // Entferne Sub-Task ID aus Parent-Task
        var updatedParent = parentTask
        var subTaskIds = updatedParent.subTaskIds ?? []
        subTaskIds.removeAll { $0 == taskId }
        updatedParent.subTaskIds = subTaskIds.isEmpty ? nil : subTaskIds
        try await updateTask(updatedParent)
        
        // Entferne parentTaskId vom Sub-Task (macht ihn zu Top-Level)
        if let subTask = allTasks.first(where: { $0.id == taskId }) {
            var updatedSubTask = subTask
            updatedSubTask.parentTaskId = nil
            try await updateTask(updatedSubTask)
        }
        
        print("✅ TaskRepository: Sub-Task '\(taskId)' von '\(parentTask.title)' entfernt")
    }
    
    /// Verschiebt einen Task zu einem neuen Parent (oder macht ihn zu Top-Level)
    func moveTask(taskId: String, newParentId: String?, newOrder: Int) async throws {
        guard let task = allTasks.first(where: { $0.id == taskId }) else {
            throw NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task nicht gefunden"])
        }
        
        let oldParentId = task.parentTaskId
        
        // Wenn Task einen alten Parent hat, entferne ihn von dort
        if let oldParentId = oldParentId, let oldParent = allTasks.first(where: { $0.id == oldParentId }) {
            var updatedOldParent = oldParent
            var subTaskIds = updatedOldParent.subTaskIds ?? []
            subTaskIds.removeAll { $0 == taskId }
            updatedOldParent.subTaskIds = subTaskIds.isEmpty ? nil : subTaskIds
            try await updateTask(updatedOldParent)
        }
        
        // Wenn Task einen neuen Parent bekommt, füge ihn dort hinzu
        if let newParentId = newParentId {
            guard let newParent = allTasks.first(where: { $0.id == newParentId }) else {
                throw NSError(domain: "TaskRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Neuer Parent-Task nicht gefunden"])
            }
            
            var updatedNewParent = newParent
            var subTaskIds = updatedNewParent.subTaskIds ?? []
            if !subTaskIds.contains(taskId) {
                subTaskIds.append(taskId)
                updatedNewParent.subTaskIds = subTaskIds
                try await updateTask(updatedNewParent)
            }
        }
        
        // Aktualisiere Task selbst
        var updatedTask = task
        updatedTask.parentTaskId = newParentId
        updatedTask.order = newOrder
        try await updateTask(updatedTask)
        
        // Aktualisiere order aller anderen Tasks im gleichen Container
        await reorderTasks(in: newParentId, excluding: taskId)
        
        print("✅ TaskRepository: Task '\(task.title)' verschoben zu Parent: \(newParentId ?? "Top-Level"), Order: \(newOrder)")
    }
    
    /// Ordnet Tasks neu (nach Drag & Drop)
    private func reorderTasks(in parentId: String?, excluding excludedTaskId: String) async {
        let tasksToReorder: [Task]
        
        if let parentId = parentId {
            // Sub-Tasks eines Parent-Tasks
            tasksToReorder = getSubTasks(for: parentId).filter { $0.id != excludedTaskId }
        } else {
            // Top-Level Tasks für heute
            tasksToReorder = getTopLevelTasks(for: Date()).filter { $0.id != excludedTaskId }
        }
        
        // Aktualisiere order für alle Tasks (außer dem verschobenen)
        for (index, task) in tasksToReorder.enumerated() {
            var updatedTask = task
            updatedTask.order = index
            do {
                try await updateTask(updatedTask)
            } catch {
                print("⚠️ TaskRepository: Fehler beim Reorder von Task '\(task.title)': \(error)")
            }
        }
    }
    
    /// Löscht einen Task und alle seine Sub-Tasks rekursiv
    func deleteTaskWithSubTasks(_ taskId: String) async throws {
        let subTasks = getSubTasks(for: taskId)
        
        // Lösche alle Sub-Tasks rekursiv
        for subTask in subTasks {
            try await deleteTaskWithSubTasks(subTask.id)
        }
        
        // Lösche den Task selbst
        try await deleteTask(taskId)
        
        // Entferne Task ID aus Parent-Task (falls vorhanden)
        if let task = allTasks.first(where: { $0.id == taskId }),
           let parentId = task.parentTaskId,
           let parentTask = allTasks.first(where: { $0.id == parentId }) {
            var updatedParent = parentTask
            var subTaskIds = updatedParent.subTaskIds ?? []
            subTaskIds.removeAll { $0 == taskId }
            updatedParent.subTaskIds = subTaskIds.isEmpty ? nil : subTaskIds
            try await updateTask(updatedParent)
        }
        
        print("✅ TaskRepository: Task '\(taskId)' und alle Sub-Tasks gelöscht")
    }
    
    /// Gibt alle Tasks in einer Hierarchie zurück (Parent + alle Sub-Tasks)
    func getTaskHierarchy(for taskId: String) -> [Task] {
        guard let task = allTasks.first(where: { $0.id == taskId }) else { return [] }
        
        var hierarchy: [Task] = [task]
        let subTasks = getSubTasks(for: taskId)
        
        for subTask in subTasks {
            hierarchy.append(contentsOf: getTaskHierarchy(for: subTask.id))
        }
        
        return hierarchy
    }
}

