//
//  DayPlan.swift
//  FocusCoach
//
//  Day Plan Model - Synchronized with Firebase
//

import Foundation

struct DayPlan: Identifiable, Codable {
    let id: String
    let userId: String
    let date: String // YYYY-MM-DD format
    var tasks: [Task]
    var createdAt: Int64
    var confirmed: Bool
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        date: String,
        tasks: [Task] = [],
        createdAt: Int64? = nil,
        confirmed: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.tasks = tasks
        self.createdAt = createdAt ?? Int64(Date().timeIntervalSince1970 * 1000)
        self.confirmed = confirmed
    }
    
    static func today() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
