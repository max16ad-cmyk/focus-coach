//
//  TaskRepeater.swift
//  FocusCoach
//
//  Service für automatische Erstellung wiederkehrender Tasks
//

import Foundation

@MainActor
class TaskRepeater {
    static let shared = TaskRepeater()
    
    private let taskRepository = TaskRepository.shared
    private let firebaseService = FirebaseService.shared
    private let calendar = Calendar.current
    
    private init() {}
    
    /// Erstellt wiederkehrende Tasks basierend auf einem Template-Task
    /// Erstellt Tasks für die nächsten N Tage (standardmäßig 30 Tage)
    func createRepeatingTasks(from templateTask: Task, daysAhead: Int = 30) async throws {
        guard let repeatPattern = templateTask.repeatPattern else {
            print("⚠️ TaskRepeater: Task '\(templateTask.title)' hat kein repeatPattern - überspringe")
            return // Keine Wiederholung
        }
        
        print("🔄 TaskRepeater: Erstelle wiederkehrende Tasks für '\(templateTask.title)' mit Pattern: \(repeatPattern)")
        
        // Basis-Datum (Startdatum der Wiederholung)
        let baseDate: Date
        if let scheduledDateString = templateTask.scheduledDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            baseDate = formatter.date(from: scheduledDateString) ?? Date()
            print("📅 TaskRepeater: Startdatum: \(scheduledDateString)")
        } else {
            baseDate = Date() // Heute als Start
            print("📅 TaskRepeater: Kein Startdatum - verwende heute")
        }
        
        // Berechne alle Daten für die Wiederholung
        let datesToCreate = calculateRepeatDates(
            baseDate: baseDate,
            repeatPattern: repeatPattern,
            repeatWeekdays: templateTask.repeatWeekdays,
            daysAhead: daysAhead
        )
        
        // Erstelle Tasks für jeden berechneten Tag
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Überspringe das Basis-Datum (Template-Task ist bereits gespeichert)
        let datesToCreateFiltered = datesToCreate.filter { date in
            !calendar.isDate(date, inSameDayAs: baseDate)
        }
        
        for date in datesToCreateFiltered {
            // Prüfe ob Task für dieses Datum bereits existiert
            let dateString = formatter.string(from: date)
            let existingTasks = taskRepository.getTasksForDate(date)
            
            // Prüfe ob bereits ein Task existiert, der von DIESEM Template-Task erstellt wurde
            // Kriterien:
            // 1. Gleicher Titel (muss exakt übereinstimmen)
            // 2. Gleiche Zeit (Start UND End)
            // 3. Kein repeatPattern (nur wiederkehrende Tasks, nicht Template)
            // 4. Gleiche Blockliste (optional, aber hilfreich für Identifikation)
            // 
            // WICHTIG: Dies verhindert nur, dass der GLEICHE Task mehrfach erstellt wird.
            // Verschiedene Tasks mit gleicher Zeit sind weiterhin möglich!
            let alreadyExists = existingTasks.contains { existingTask in
                // Gleicher Titel UND gleiche Zeit = gleicher Task
                let sameTitle = existingTask.title == templateTask.title
                let sameTime = existingTask.scheduledStartTime == templateTask.scheduledStartTime &&
                              existingTask.scheduledEndTime == templateTask.scheduledEndTime
                let isRepeatingTask = existingTask.repeatPattern == nil // Kein Pattern = wiederkehrender Task
                
                return sameTitle && sameTime && isRepeatingTask
            }
            
            if !alreadyExists {
                // Erstelle neuen Task für dieses Datum
                let newTask = Task(
                    id: UUID().uuidString,
                    title: templateTask.title,
                    completed: false,
                    createdAt: Int64(Date().timeIntervalSince1970 * 1000),
                    scheduledDate: dateString,
                    scheduledStartTime: templateTask.scheduledStartTime,
                    scheduledEndTime: templateTask.scheduledEndTime,
                    repeatPattern: nil, // Wiederholungsinfo nur im Template-Task
                    repeatWeekdays: nil,
                    notes: templateTask.notes,
                    blockListId: templateTask.blockListId,
                    routineId: templateTask.routineId // Behalte routineId für Routinen-Tasks
                )
                
                // Debug-Logging für Routinen-Tasks
                if let routineId = templateTask.routineId {
                    print("🔄 TaskRepeater: Erstelle Task '\(newTask.title)' für Routine '\(routineId)' am \(dateString)")
                }
                
                // Speichere Task direkt über FirebaseService (ohne TaskRepository, um Endlosschleife zu vermeiden)
                try await firebaseService.saveTask(newTask)
                print("✅ TaskRepeater: Task erstellt für \(dateString): '\(templateTask.title)'")
            }
        }
    }
    
    /// Berechnet alle Daten für eine Wiederholung
    private func calculateRepeatDates(
        baseDate: Date,
        repeatPattern: RepeatPattern,
        repeatWeekdays: RepeatWeekdays?,
        daysAhead: Int
    ) -> [Date] {
        var dates: [Date] = []
        let endDate = calendar.date(byAdding: .day, value: daysAhead, to: baseDate) ?? baseDate
        
        switch repeatPattern {
        case .daily:
            // Täglich: Jeden Tag
            var currentDate = calendar.startOfDay(for: baseDate)
            while currentDate <= endDate {
                dates.append(currentDate)
                if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDate
                } else {
                    break
                }
            }
            
        case .weekly:
            if let weekdays = repeatWeekdays {
                // Wöchentlich an bestimmten Wochentagen
                var currentDate = calendar.startOfDay(for: baseDate)
                while currentDate <= endDate {
                    let weekday = calendar.component(.weekday, from: currentDate)
                    if shouldIncludeWeekday(weekday, in: weekdays) {
                        dates.append(currentDate)
                    }
                    if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                        currentDate = nextDate
                    } else {
                        break
                    }
                }
            } else {
                // Wöchentlich am gleichen Wochentag
                let baseWeekday = calendar.component(.weekday, from: baseDate)
                var currentDate = calendar.startOfDay(for: baseDate)
                
                while currentDate <= endDate {
                    let weekday = calendar.component(.weekday, from: currentDate)
                    if weekday == baseWeekday {
                        dates.append(currentDate)
                        // Nächste Woche
                        if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
                            currentDate = nextWeek
                        } else {
                            break
                        }
                    } else {
                        // Nächster Tag
                        if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                            currentDate = nextDay
                        } else {
                            break
                        }
                    }
                }
            }
            
        case .monthly:
            // Monatlich: Am gleichen Tag des Monats
            var currentDate = calendar.startOfDay(for: baseDate)
            while currentDate <= endDate {
                dates.append(currentDate)
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                    currentDate = nextMonth
                } else {
                    break
                }
            }
            
        case .weekdays:
            // Bestimmte Wochentage (aus repeatWeekdays)
            if let weekdays = repeatWeekdays {
                var currentDate = calendar.startOfDay(for: baseDate)
                while currentDate <= endDate {
                    let weekday = calendar.component(.weekday, from: currentDate)
                    if shouldIncludeWeekday(weekday, in: weekdays) {
                        dates.append(currentDate)
                    }
                    if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                        currentDate = nextDate
                    } else {
                        break
                    }
                }
            } else {
                // Fallback: Nur Werktage (Mo-Fr) wenn keine Wochentage angegeben
                var currentDate = calendar.startOfDay(for: baseDate)
                while currentDate <= endDate {
                    let weekday = calendar.component(.weekday, from: currentDate)
                    // Montag = 2, Freitag = 6
                    if weekday >= 2 && weekday <= 6 {
                        dates.append(currentDate)
                    }
                    if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                        currentDate = nextDate
                    } else {
                        break
                    }
                }
            }
        }
        
        return dates
    }
    
    /// Prüft ob ein Wochentag in den ausgewählten Wochentagen enthalten ist
    private func shouldIncludeWeekday(_ weekday: Int, in repeatWeekdays: RepeatWeekdays) -> Bool {
        switch weekday {
        case 1: return repeatWeekdays.sunday   // Sonntag
        case 2: return repeatWeekdays.monday   // Montag
        case 3: return repeatWeekdays.tuesday  // Dienstag
        case 4: return repeatWeekdays.wednesday // Mittwoch
        case 5: return repeatWeekdays.thursday  // Donnerstag
        case 6: return repeatWeekdays.friday   // Freitag
        case 7: return repeatWeekdays.saturday // Samstag
        default: return false
        }
    }
    
    /// Prüft täglich, ob neue wiederkehrende Tasks erstellt werden müssen
    func checkAndCreateRepeatingTasks() async {
        // Finde alle Tasks mit Wiederholungsmuster
        let repeatingTasks = taskRepository.allTasks.filter { $0.repeatPattern != nil }
        
        for templateTask in repeatingTasks {
            do {
                try await createRepeatingTasks(from: templateTask, daysAhead: 7) // Erstelle für nächste 7 Tage
            } catch {
                print("⚠️ Fehler beim Erstellen wiederkehrender Tasks für '\(templateTask.title)': \(error)")
            }
        }
    }
}

