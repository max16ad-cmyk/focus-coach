//
//  BlockList.swift
//  FocusCoach
//
//  BlockList Model - Verwaltet Blocklisten für Apps und URLs
//

import Foundation
import FamilyControls
import ManagedSettings

struct BlockList: Identifiable, Codable {
    let id: String
    var name: String
    var appTokens: Set<ApplicationToken>  // Für iOS/macOS Apps (als Data gespeichert)
    var urls: [String]                     // Für URLs (alle Plattformen)
    
    // Multi-Platform App-Identifikatoren
    var appIdentifiers: MultiPlatformAppIdentifiers? // Für Cross-Platform Sync
    
    var createdAt: Date
    var updatedAt: Date
    var isDefault: Bool                    // Standard-Blockliste
    var familyActivitySelectionData: Data? // Gespeicherte FamilyActivitySelection für Icons
    
    init(
        id: String = UUID().uuidString,
        name: String,
        appTokens: Set<ApplicationToken> = [],
        urls: [String] = [],
        appIdentifiers: MultiPlatformAppIdentifiers? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDefault: Bool = false,
        familyActivitySelectionData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.appTokens = appTokens
        self.urls = urls
        self.appIdentifiers = appIdentifiers
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDefault = isDefault
        self.familyActivitySelectionData = familyActivitySelectionData
    }
    
    /// Lädt FamilyActivitySelection für Icon-Anzeige
    func loadFamilyActivitySelection() -> FamilyActivitySelection? {
        guard let data = familyActivitySelectionData else { return nil }
        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }
    
    // MARK: - Codable für ApplicationToken
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case appTokensData  // Als Data speichern
        case urls
        case appIdentifiers  // Multi-Platform Identifikatoren
        case createdAt
        case updatedAt
        case isDefault
        case familyActivitySelectionData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        urls = try container.decode([String].self, forKey: .urls)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
        
        // Decode ApplicationTokens from Data
        if let tokensData = try? container.decode(Data.self, forKey: .appTokensData) {
            // ApplicationTokens müssen über FamilyActivitySelection gespeichert werden
            // Für jetzt: Leeres Set, wird später über BlockListRepository geladen
            appTokens = []
        } else {
            appTokens = []
        }
        
        // Decode FamilyActivitySelection Data
        familyActivitySelectionData = try? container.decodeIfPresent(Data.self, forKey: .familyActivitySelectionData)
        
        // Decode Multi-Platform App Identifiers
        appIdentifiers = try? container.decodeIfPresent(MultiPlatformAppIdentifiers.self, forKey: .appIdentifiers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(urls, forKey: .urls)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(isDefault, forKey: .isDefault)
        
        // ApplicationTokens müssen über FamilyActivitySelection gespeichert werden
        // Für jetzt: Leeres Data, wird später über BlockListRepository gespeichert
        try container.encode(Data(), forKey: .appTokensData)
        try container.encodeIfPresent(familyActivitySelectionData, forKey: .familyActivitySelectionData)
        
        // Encode Multi-Platform App Identifiers
        try container.encodeIfPresent(appIdentifiers, forKey: .appIdentifiers)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: BlockList, rhs: BlockList) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.urls == rhs.urls &&
               lhs.createdAt == rhs.createdAt &&
               lhs.updatedAt == rhs.updatedAt &&
               lhs.isDefault == rhs.isDefault &&
               lhs.appTokens.count == rhs.appTokens.count
        // Note: ApplicationToken Vergleich ist komplex, daher nur Count-Vergleich
    }
}

// MARK: - Multi-Platform App Identifiers

/// Speichert App-Identifikatoren für verschiedene Plattformen
struct MultiPlatformAppIdentifiers: Codable {
    var ios: [String] = []        // Bundle IDs (z.B. "com.instagram.instagram")
    var macos: [String] = []      // Bundle IDs (z.B. "com.instagram.instagram")
    var windows: [String] = []    // App-Namen oder Executable-Namen (z.B. "Instagram.exe")
    var web: [String] = []       // Domain-Namen (z.B. "instagram.com")
    
    /// Konvertiert iOS Bundle IDs zu anderen Plattformen
    static func fromIOSBundleIds(_ bundleIds: [String]) -> MultiPlatformAppIdentifiers {
        var identifiers = MultiPlatformAppIdentifiers()
        identifiers.ios = bundleIds
        identifiers.macos = bundleIds // macOS nutzt oft gleiche Bundle IDs
        
        // Mapping für bekannte Apps
        let appMapping: [String: (windows: String, web: String)] = [
            "com.instagram.instagram": ("Instagram.exe", "instagram.com"),
            "com.tiktok.TikTok": ("TikTok.exe", "tiktok.com"),
            "com.google.ios.youtube": ("YouTube.exe", "youtube.com"),
            "com.facebook.Facebook": ("Facebook.exe", "facebook.com"),
            "com.twitter.twitter": ("Twitter.exe", "twitter.com"),
            "com.snapchat.snapchat": ("Snapchat.exe", "snapchat.com"),
            "com.reddit.Reddit": ("Reddit.exe", "reddit.com"),
            "com.twitch.twitch": ("Twitch.exe", "twitch.tv")
        ]
        
        for bundleId in bundleIds {
            if let mapping = appMapping[bundleId] {
                identifiers.windows.append(mapping.windows)
                identifiers.web.append(mapping.web)
            }
        }
        
        return identifiers
    }
    
    /// Extrahiert Bundle IDs aus ApplicationTokens (für iOS/macOS)
    static func extractBundleIds(from tokens: Set<ApplicationToken>) -> [String] {
        // ApplicationToken kann nicht direkt zu Bundle ID konvertiert werden
        // Wir müssen die Bundle IDs separat speichern
        // Für jetzt: Leer, wird später über App-Mapping gelöst
        return []
    }
}

