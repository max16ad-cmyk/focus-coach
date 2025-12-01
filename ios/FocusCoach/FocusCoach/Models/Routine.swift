//
//  Routine.swift
//  FocusCoach
//
//  Routine Model - Wiederkehrende Aufgaben (z.B. Morgen Routine, Sport)
//

import Foundation

struct Routine: Identifiable, Codable {
    let id: String
    var name: String
    var description: String?
    var tasks: [RoutineTask] // Tasks die zur Routine gehören
    var repeatPattern: RepeatPattern
    var repeatWeekdays: RepeatWeekdays?
    var isActive: Bool
    var createdAt: Int64
    var updatedAt: Int64
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        tasks: [RoutineTask] = [],
        repeatPattern: RepeatPattern = .daily,
        repeatWeekdays: RepeatWeekdays? = nil,
        isActive: Bool = true,
        createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000),
        updatedAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.tasks = tasks
        self.repeatPattern = repeatPattern
        self.repeatWeekdays = repeatWeekdays
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct RoutineTask: Identifiable, Codable {
    let id: String
    var title: String
    var startTime: String? // HH:mm Format
    var endTime: String? // HH:mm Format
    var duration: Int? // Minuten
    var notes: String?
    var order: Int // Reihenfolge in der Routine
    
    init(
        id: String = UUID().uuidString,
        title: String,
        startTime: String? = nil,
        endTime: String? = nil,
        duration: Int? = nil,
        notes: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.notes = notes
        self.order = order
    }
}



