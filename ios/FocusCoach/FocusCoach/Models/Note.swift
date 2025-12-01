//
//  Note.swift
//  FocusCoach
//
//  Note Model - For Notes Tab
//

import Foundation

struct Note: Identifiable, Codable {
    let id: String
    var title: String
    var content: String
    var category: NoteCategory?
    var checklist: [ChecklistItem]?
    var createdAt: Int64
    var updatedAt: Int64
    
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String = "",
        category: NoteCategory? = nil,
        checklist: [ChecklistItem]? = nil,
        createdAt: Int64? = nil,
        updatedAt: Int64? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.checklist = checklist
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        self.createdAt = createdAt ?? now
        self.updatedAt = updatedAt ?? now
    }
}

enum NoteCategory: String, Codable {
    case allgemein = "Allgemein"
    case arbeit = "Arbeit"
    case privat = "Privat"
    case ideen = "Ideen"
}

struct ChecklistItem: Identifiable, Codable {
    let id: String
    var text: String
    var completed: Bool
    
    init(id: String = UUID().uuidString, text: String, completed: Bool = false) {
        self.id = id
        self.text = text
        self.completed = completed
    }
}




