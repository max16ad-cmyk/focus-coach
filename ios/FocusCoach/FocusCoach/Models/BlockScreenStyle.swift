//
//  BlockScreenStyle.swift
//  FocusCoach
//
//  Block Screen Style Model - Custom Messages for Blocking Screen
//

import Foundation

enum BlockScreenStyle: String, Codable, CaseIterable {
    case standard = "Standard"
    case motivational = "Motivierend"
    case haiku = "Fokus-Haiku"
    case quote = "Inspirierend"
    case strict = "Streng"
    case custom = "Benutzerdefiniert"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .standard: return "shield"
        case .motivational: return "heart.fill"
        case .haiku: return "text.quote"
        case .quote: return "sparkles"
        case .strict: return "exclamationmark.triangle.fill"
        case .custom: return "pencil"
        }
    }
    
    var defaultMessage: String {
        switch self {
        case .standard:
            return "Diese App wird von Focus Coach blockiert."
        case .motivational:
            return "Du schaffst das! Bleib fokussiert. 💪"
        case .haiku:
            return "Fokus ist der Schlüssel\nZu deinem Erfolg heute\nBleib bei deinen Tasks"
        case .quote:
            return "Die Zukunft gehört denen, die heute produktiv sind."
        case .strict:
            return "⛔ Fokus-Session aktiv! Keine Ablenkungen erlaubt."
        case .custom:
            return "Fokus-Session aktiv"
        }
    }
}

struct CustomBlockScreen: Codable {
    var style: BlockScreenStyle
    var customMessage: String?
    var backgroundImageName: String? // Name des Hintergrundbildes (z.B. "sunset", "mountains", etc.)
    
    var displayMessage: String {
        if style == .custom, let message = customMessage, !message.isEmpty {
            return message
        }
        return style.defaultMessage
    }
    
    var backgroundImage: String? {
        return backgroundImageName
    }
}

// MARK: - Background Image Options

enum BlockScreenBackground: String, Codable, CaseIterable {
    case sunset = "sunset"
    case mountains = "mountains"
    case riceTerraces = "riceTerraces"
    case pyramid = "pyramid"
    case desertDog = "desertDog"
    case zebra = "zebra"
    case alpineForest = "alpineForest"
    case almHut = "almHut"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .sunset: return "Sonnenuntergang"
        case .mountains: return "Berge"
        case .riceTerraces: return "Reisterrassen"
        case .pyramid: return "Pyramide"
        case .desertDog: return "Wüste"
        case .zebra: return "Savanne"
        case .alpineForest: return "Alpenwald"
        case .almHut: return "Almhütte"
        case .none: return "Kein Hintergrund"
        }
    }
    
    var imageName: String {
        return rawValue
    }
}

