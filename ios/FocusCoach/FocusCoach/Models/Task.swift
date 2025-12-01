//
//  Task.swift
//  FocusCoach
//
//  Task Model - Synchronized with Firebase
//

import Foundation

enum TaskCategory: String, Codable {
    case lernen = "Lernen"
    case haushalt = "Haushalt"
    case erledigung = "Erledigung"
    case arbeit = "Arbeit"
    case sport = "Sport"
    case kreativ = "Kreativ"
}

enum TaskStatus: String, Codable {
    case pending = "pending"
    case inProgress = "in_progress"
    case waitingProof = "waiting_proof"
    case completed = "completed"
    case skipped = "skipped"
}

enum ProofType: String, Codable {
    case photo = "photo"
    case document = "document"
    case screenshot = "screenshot"
}

enum RepeatPattern: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case weekdays = "weekdays" // Specific weekdays
}

struct RepeatWeekdays: Codable {
    var monday: Bool = false
    var tuesday: Bool = false
    var wednesday: Bool = false
    var thursday: Bool = false
    var friday: Bool = false
    var saturday: Bool = false
    var sunday: Bool = false
    
    var selectedDays: [Int] {
        var days: [Int] = []
        if monday { days.append(2) } // Monday = 2 in Calendar
        if tuesday { days.append(3) }
        if wednesday { days.append(4) }
        if thursday { days.append(5) }
        if friday { days.append(6) }
        if saturday { days.append(7) }
        if sunday { days.append(1) }
        return days
    }
    
    var displayText: String {
        let days = [
            (monday, "Mo"),
            (tuesday, "Di"),
            (wednesday, "Mi"),
            (thursday, "Do"),
            (friday, "Fr"),
            (saturday, "Sa"),
            (sunday, "So")
        ]
        let selected = days.filter { $0.0 }.map { $0.1 }
        return selected.isEmpty ? "" : selected.joined(separator: ", ")
    }
}

enum TaskPriority: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

struct Task: Identifiable, Codable {
    let id: String
    var title: String
    var completed: Bool
    var isAiGenerated: Bool?
    var verificationRequired: Bool?
    var category: TaskCategory?
    var duration: Int? // in minutes
    var requiresProof: Bool?
    var proofType: ProofType?
    var proofDescription: String?
    var suggestedStartTime: String? // HH:mm format
    var suggestedEndTime: String? // HH:mm format
    var status: TaskStatus?
    var proofImageUrl: String?
    var verified: Bool?
    var createdAt: Int64?
    var scheduledDate: String? // YYYY-MM-DD format for planning
    var scheduledStartTime: String? // HH:mm format (e.g. "09:00")
    var scheduledEndTime: String? // HH:mm format (e.g. "10:00")
    var repeatPattern: RepeatPattern?
    var repeatWeekdays: RepeatWeekdays? // For weekly repeats with specific days
    var priority: TaskPriority?
    var notes: String? // Optional notes for the task
    var blockListId: String? // ID der zugeordneten Blockliste (nil = Standard-Blockliste)
    var routineId: String? // ID der Routine, aus der dieser Task erstellt wurde (nil = normaler Task)
    
    // Block-System & Hierarchie
    var parentTaskId: String? // ID des Parent-Tasks (für verschachtelte Tasks)
    var subTaskIds: [String]? // IDs der Sub-Tasks (für Hierarchie)
    var order: Int? // Reihenfolge innerhalb der Parent-Task oder Liste
    
    init(
        id: String = UUID().uuidString,
        title: String,
        completed: Bool = false,
        isAiGenerated: Bool? = nil,
        verificationRequired: Bool? = nil,
        category: TaskCategory? = nil,
        duration: Int? = nil,
        requiresProof: Bool? = nil,
        proofType: ProofType? = nil,
        proofDescription: String? = nil,
        suggestedStartTime: String? = nil,
        suggestedEndTime: String? = nil,
        status: TaskStatus? = .pending,
        proofImageUrl: String? = nil,
        verified: Bool? = nil,
        createdAt: Int64? = nil,
        scheduledDate: String? = nil,
        scheduledStartTime: String? = nil,
        scheduledEndTime: String? = nil,
        repeatPattern: RepeatPattern? = nil,
        repeatWeekdays: RepeatWeekdays? = nil,
        priority: TaskPriority? = nil,
        notes: String? = nil,
        blockListId: String? = nil,
        routineId: String? = nil,
        parentTaskId: String? = nil,
        subTaskIds: [String]? = nil,
        order: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.completed = completed
        self.isAiGenerated = isAiGenerated
        self.verificationRequired = verificationRequired
        self.category = category
        self.duration = duration
        self.requiresProof = requiresProof
        self.proofType = proofType
        self.proofDescription = proofDescription
        self.suggestedStartTime = suggestedStartTime
        self.suggestedEndTime = suggestedEndTime
        self.status = status
        self.proofImageUrl = proofImageUrl
        self.verified = verified
        self.createdAt = createdAt ?? Int64(Date().timeIntervalSince1970 * 1000)
        self.scheduledDate = scheduledDate
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.repeatPattern = repeatPattern
        self.repeatWeekdays = repeatWeekdays
        self.priority = priority
        self.notes = notes
        self.blockListId = blockListId
        self.routineId = routineId
        self.parentTaskId = parentTaskId
        self.subTaskIds = subTaskIds
        self.order = order
    }
    
    var hasTimeSlot: Bool {
        scheduledStartTime != nil && scheduledEndTime != nil
    }
    
    // Block-System Helper
    var isParentTask: Bool {
        guard let subTaskIds = subTaskIds else { return false }
        return !subTaskIds.isEmpty
    }
    
    var isSubTask: Bool {
        return parentTaskId != nil
    }
    
    var hasSubTasks: Bool {
        return isParentTask
    }
}
