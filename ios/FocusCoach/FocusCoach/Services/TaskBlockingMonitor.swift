//
//  TaskBlockingMonitor.swift
//  FocusCoach
//
//  Monitors tasks and manages blocking based on active tasks
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings

@MainActor
class TaskBlockingMonitor: ObservableObject {
    static let shared = TaskBlockingMonitor()
    
    private let blockingService = BlockingService.shared
    private let taskRepository = TaskRepository.shared
    private let blockListRepository = BlockListRepository.shared
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var activeTasks: [Task] = []
    
    private init() {
        // Subscribe to task changes from TaskRepository
        taskRepository.$allTasks
            .sink { [weak self] _ in
                self?.checkActiveTasks()
            }
            .store(in: &cancellables)
        
        startMonitoring()
    }
    
    /// Startet kontinuierliches Monitoring
    func startMonitoring() {
        // Prüfe alle 10 Sekunden (häufiger für bessere Reaktionszeit)
        timer = Timer.scheduledTimer(
            timeInterval: 10.0,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )
        
        // Initial check sofort
        checkActiveTasks()
        
        // Zusätzlicher Check nach 2 Sekunden (für Fallback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkActiveTasks()
        }
    }
    
    @objc private func timerFired() {
        checkActiveTasks()
    }
    
    /// Stoppt Monitoring
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Prüft aktive Tasks und aktualisiert Blockierung
    func checkActiveTasks() {
        guard blockingService.isAuthorized else {
            return
        }
        
        // WICHTIG: Prüfe ob Blockierung manuell aktiviert ist (überschreibt Zeitprüfung)
        // Wenn isBlockingActive = true UND manuell aktiviert, blockiere immer
        // (außer wenn explizit deaktiviert)
        
        // Lade alle Tasks für heute von TaskRepository
        let today = getTodayString()
        let allTasks = taskRepository.getTasksForToday()
        
        print("🔍 TaskBlockingMonitor: Prüfe \(allTasks.count) Tasks für heute (\(today))")
        
        // Filtere aktive Tasks
        var active: [Task] = []
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        for task in allTasks {
            // Überspringe erledigte Tasks
            if task.completed {
                continue
            }
            
            // WICHTIG: Prüfe zuerst das Datum, bevor wir über Zeit entscheiden
            let taskDate = task.scheduledDate ?? today
            
            // Task ist für die Zukunft geplant → NICHT blockieren
            if taskDate > today {
                print("📅 TaskBlockingMonitor: Task '\(task.title)' ist für \(taskDate) geplant (heute: \(today)) → NICHT blockieren")
                continue
            }
            
            // Task ist für die Vergangenheit → NICHT blockieren (wenn nicht erledigt, aber schon vorbei)
            if taskDate < today {
                print("📅 TaskBlockingMonitor: Task '\(task.title)' ist für \(taskDate) geplant (heute: \(today)) → NICHT blockieren")
                continue
            }
            
            // Task ist für heute → prüfe Zeit
            // Tasks ohne Zeit: immer blockieren (nur wenn für heute)
            if !task.hasTimeSlot {
                active.append(task)
                print("✅ TaskBlockingMonitor: Task '\(task.title)' ist aktiv (ohne Zeit, für heute)")
                continue
            }
            
            // Tasks mit Zeit: nur während der geplanten Zeit blockieren
            if let startTimeString = task.scheduledStartTime,
               let endTimeString = task.scheduledEndTime {
                
                // Konvertiere Zeit-Strings zu Minuten für korrekten Vergleich
                if let startTimeInMinutes = timeStringToMinutes(startTimeString),
                   let endTimeInMinutes = timeStringToMinutes(endTimeString) {
                    
                    // Prüfe ob aktuelle Zeit innerhalb des Zeitfensters liegt
                    // WICHTIG: Nur blockieren wenn AKTUELLE Zeit >= Start UND <= Ende
                    if currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes <= endTimeInMinutes {
                        active.append(task)
                        print("✅ TaskBlockingMonitor: Task '\(task.title)' ist aktiv (Zeit: \(startTimeString)-\(endTimeString), Aktuell: \(String(format: "%02d:%02d", currentHour, currentMinute)))")
                    } else {
                        // Task ist noch nicht aktiv oder bereits vorbei
                        let timeUntilStart = startTimeInMinutes - currentTimeInMinutes
                        if timeUntilStart > 0 {
                            print("⏳ TaskBlockingMonitor: Task '\(task.title)' startet in \(timeUntilStart) Minuten (Zeit: \(startTimeString)-\(endTimeString))")
                        } else {
                            print("⏰ TaskBlockingMonitor: Task '\(task.title)' ist bereits vorbei (Zeit: \(startTimeString)-\(endTimeString))")
                        }
                    }
                }
            }
        }
        
        // Aktualisiere Blockierung
        activeTasks = active
        
        if !active.isEmpty {
            // Sammle alle Blocklisten von aktiven Tasks
            var allAppTokens: Set<ApplicationToken> = []
            var allURLs: [String] = []
            
            for task in active {
                // Hole Blockliste für Task (oder Standard-Blockliste)
                let blockList: BlockList?
                if let blockListId = task.blockListId {
                    blockList = blockListRepository.getBlockList(id: blockListId)
                } else {
                    blockList = blockListRepository.defaultBlockList
                }
                
                // Füge Apps und URLs hinzu
                if let blockList = blockList {
                    allAppTokens.formUnion(blockList.appTokens)
                    allURLs.append(contentsOf: blockList.urls)
                }
            }
            
            // Aktualisiere Status in BlockingService
            blockingService.updateActiveTasksStatus(true)
            
            // WICHTIG: Wenn keine Blockliste vorhanden ist, verwende Standard-Blockliste
            if allAppTokens.isEmpty {
                // Verwende Standard-Blockliste wenn keine spezifische Blockliste vorhanden
                if let defaultBlockList = blockListRepository.defaultBlockList {
                    allAppTokens = defaultBlockList.appTokens
                    allURLs = defaultBlockList.urls
                    print("📋 TaskBlockingMonitor: Verwende Standard-Blockliste mit \(allAppTokens.count) Apps (aus Blockliste)")
                    
                    // FALLBACK: Wenn Standard-Blockliste keine Apps hat, verwende BlockingService.familyActivitySelection
                    if allAppTokens.isEmpty {
                        let blockingService = BlockingService.shared
                        let serviceApps = blockingService.familyActivitySelection.applicationTokens
                        print("📋 TaskBlockingMonitor: Standard-Blockliste hat keine Apps - prüfe BlockingService.familyActivitySelection...")
                        print("   - BlockingService.familyActivitySelection: \(serviceApps.count) Apps gefunden")
                        
                        if !serviceApps.isEmpty {
                            allAppTokens = serviceApps
                            print("✅ TaskBlockingMonitor: Fallback aktiviert - Verwende \(serviceApps.count) Apps aus BlockingService")
                            
                            // Aktualisiere auch die Standard-Blockliste mit diesen Apps
                            var updatedDefaultList = defaultBlockList
                            updatedDefaultList.appTokens = serviceApps
                            blockListRepository.updateBlockListWithSelection(
                                updatedDefaultList.id,
                                selection: blockingService.familyActivitySelection
                            )
                            print("💾 TaskBlockingMonitor: Standard-Blockliste aktualisiert mit \(serviceApps.count) Apps")
                        } else {
                            print("⚠️ TaskBlockingMonitor: BlockingService.familyActivitySelection ist auch leer!")
                        }
                    }
                } else {
                    // FALLBACK: Verwende direkt BlockingService.familyActivitySelection
                    let blockingService = BlockingService.shared
                    allAppTokens = blockingService.familyActivitySelection.applicationTokens
                    print("📋 TaskBlockingMonitor: Keine Standard-Blockliste - verwende BlockingService.familyActivitySelection mit \(allAppTokens.count) Apps")
                }
            }
            
            // Aktiviere Blockierung mit gesammelten Apps und URLs
            if !allAppTokens.isEmpty {
                print("🔒 TaskBlockingMonitor: Aktiviere Blockierung für \(allAppTokens.count) Apps")
                blockingService.blockApps(allAppTokens)
            } else {
                print("⚠️ TaskBlockingMonitor: Keine Apps zum Blockieren vorhanden!")
            }
            
            if !allURLs.isEmpty {
                print("🔒 TaskBlockingMonitor: Aktiviere URL-Blockierung für \(allURLs.count) URLs")
                blockingService.blockSpecificWebsites(allURLs)
            }
        } else {
            // Aktualisiere Status in BlockingService
            blockingService.updateActiveTasksStatus(false)
            
            // Deaktiviere Blockierung wenn keine aktiven Tasks
            // WICHTIG: Nur deaktivieren wenn nicht manuell aktiviert
            if !blockingService.isBlockingActive || blockingService.blockedAppTokens.isEmpty {
                blockingService.unblockApps()
            }
        }
        
        print("📊 TaskBlockingMonitor: \(active.count) aktive Task(s) von \(allTasks.count) Tasks")
        
        // Debug: Zeige Details der aktiven Tasks
        if !active.isEmpty {
            print("📋 Aktive Tasks:")
            for task in active {
                let blockListId = task.blockListId ?? "Standard"
                print("   - '\(task.title)' (Blockliste: \(blockListId))")
            }
        } else {
            print("ℹ️ Keine aktiven Tasks - Blockierung wird deaktiviert")
        }
    }
    
    /// Konvertiert Zeit-String (HH:mm) zu Minuten seit Mitternacht
    private func timeStringToMinutes(_ timeString: String) -> Int? {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]),
              hours >= 0 && hours < 24,
              minutes >= 0 && minutes < 60 else {
            return nil
        }
        return hours * 60 + minutes
    }
    
    /// Gibt heutiges Datum als String zurück
    private func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    /// Aktualisiert Tasks manuell (wird von Views aufgerufen)
    func updateTasks(_ tasks: [Task]) {
        activeTasks = tasks
        checkActiveTasks()
    }
}

