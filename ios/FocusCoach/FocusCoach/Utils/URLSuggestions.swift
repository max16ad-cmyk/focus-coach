//
//  URLSuggestions.swift
//  FocusCoach
//
//  URL-Vorschläge und Suchfunktion
//

import Foundation

struct URLSuggestions {
    // Bekannte Websites mit Vorschlägen
    static let popularDomains: [String: String] = [
        "youtube": "youtube.com",
        "instagram": "instagram.com",
        "facebook": "facebook.com",
        "twitter": "twitter.com",
        "x": "x.com",
        "tiktok": "tiktok.com",
        "reddit": "reddit.com",
        "linkedin": "linkedin.com",
        "pinterest": "pinterest.com",
        "snapchat": "snapchat.com",
        "whatsapp": "whatsapp.com",
        "telegram": "telegram.org",
        "discord": "discord.com",
        "netflix": "netflix.com",
        "spotify": "spotify.com",
        "amazon": "amazon.de",
        "ebay": "ebay.de",
        "google": "google.com",
        "gmail": "gmail.com",
        "outlook": "outlook.com",
        "github": "github.com",
        "stackoverflow": "stackoverflow.com",
        "wikipedia": "wikipedia.org",
        "twitch": "twitch.tv",
        "vimeo": "vimeo.com",
        "dailymotion": "dailymotion.com"
    ]
    
    /// Sucht nach URL-Vorschlägen basierend auf Eingabe
    static func searchSuggestions(for query: String) -> [String] {
        let lowercaseQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        
        guard !lowercaseQuery.isEmpty else {
            return Array(popularDomains.values).sorted()
        }
        
        var suggestions: [String] = []
        
        // Exakte Übereinstimmungen zuerst
        if let exactMatch = popularDomains[lowercaseQuery] {
            suggestions.append(exactMatch)
        }
        
        // Teilübereinstimmungen
        for (key, domain) in popularDomains {
            if key.contains(lowercaseQuery) || domain.contains(lowercaseQuery) {
                if !suggestions.contains(domain) {
                    suggestions.append(domain)
                }
            }
        }
        
        // Wenn keine Übereinstimmung gefunden, füge die Eingabe als Domain hinzu
        if suggestions.isEmpty {
            // Prüfe ob es bereits eine Domain ist
            if lowercaseQuery.contains(".") {
                suggestions.append(lowercaseQuery)
            } else {
                // Füge .com hinzu als Vorschlag
                suggestions.append("\(lowercaseQuery).com")
            }
        }
        
        return suggestions
    }
    
    /// Normalisiert eine URL (entfernt http://, https://, www.)
    static func normalizeURL(_ url: String) -> String {
        var normalized = url.trimmingCharacters(in: .whitespaces)
        
        // Entferne Protokoll
        if normalized.hasPrefix("http://") {
            normalized = String(normalized.dropFirst(7))
        } else if normalized.hasPrefix("https://") {
            normalized = String(normalized.dropFirst(8))
        }
        
        // Entferne www.
        if normalized.hasPrefix("www.") {
            normalized = String(normalized.dropFirst(4))
        }
        
        // Entferne trailing slash
        if normalized.hasSuffix("/") {
            normalized = String(normalized.dropLast())
        }
        
        return normalized
    }
}



