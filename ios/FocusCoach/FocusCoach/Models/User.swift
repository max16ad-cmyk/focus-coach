//
//  User.swift
//  FocusCoach
//
//  User Model
//

import Foundation

struct User: Identifiable, Codable {
    let id: String // Firebase UID
    let email: String
    var name: String
    
    init(id: String, email: String, name: String? = nil) {
        self.id = id
        self.email = email
        self.name = name ?? email.components(separatedBy: "@").first ?? "User"
    }
}
