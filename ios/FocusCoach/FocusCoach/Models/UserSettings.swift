//
//  UserSettings.swift
//  FocusCoach
//
//  User Settings Model - Synchronized with Firebase
//

import Foundation

enum CoachPersonality: String, Codable {
    case sergeant = "sergeant"
    case professor = "professor"
    case mentor = "mentor"
    case minimalist = "minimalist"
}

enum ProofStrictness: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

struct UserSettings: Codable, Equatable {
    var coachPersonality: CoachPersonality
    var nightModeStart: String // "23:00"
    var nightModeEnd: String   // "06:00"
    var blockedSites: [String]
    var allowedSites: [String]
    var requirePhotoProof: Bool
    var proofStrictness: ProofStrictness
    var emergencyUnlockEnabled: Bool
    var emergencyUnlockDuration: Int // minutes
    var emergencyUnlockCooldown: Int // hours
    var nightModeEnabled: Bool
    var nightModeNoUnlock: Bool
    var morningLockEnabled: Bool
    var morningLockStart: String // "06:00"
    var morningLockEnd: String   // "12:00"
    
    static let `default` = UserSettings(
        coachPersonality: .sergeant,
        nightModeStart: "23:00",
        nightModeEnd: "06:00",
        blockedSites: [],
        allowedSites: [],
        requirePhotoProof: true,
        proofStrictness: .medium,
        emergencyUnlockEnabled: true,
        emergencyUnlockDuration: 5,
        emergencyUnlockCooldown: 24,
        nightModeEnabled: true,
        nightModeNoUnlock: true,
        morningLockEnabled: false,
        morningLockStart: "06:00",
        morningLockEnd: "12:00"
    )
}
