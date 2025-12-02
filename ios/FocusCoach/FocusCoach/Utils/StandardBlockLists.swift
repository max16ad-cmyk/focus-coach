//
//  StandardBlockLists.swift
//  FocusCoach
//
//  Standard-Blocklisten mit bekannten Apps und URLs
//

import Foundation

struct StandardBlockLists {
    // Bekannte Bundle IDs für Social Media Apps
    static let socialMediaBundleIDs: [String] = [
        "com.instagram.instagram",
        "com.facebook.Facebook",
        "com.tiktok.TikTok",
        "com.twitter.twitter",
        "com.snapchat.snapchat",
        "com.linkedin.linkedin",
        "com.pinterest.pinterest",
        "com.reddit.reddit",
        "com.discord.discord",
        "com.whatsapp.WhatsApp",
        "com.telegram.Telegram",
        "com.tencent.xin"
    ]
    
    // Bekannte Bundle IDs für Entertainment Apps
    static let entertainmentBundleIDs: [String] = [
        "com.google.ios.youtube",
        "com.netflix.Netflix",
        "com.spotify.client",
        "com.apple.music",
        "com.amazon.aiv.AIVApp",
        "com.hulu.plus",
        "com.disney.disneyplus",
        "com.plexapp.plex",
        "com.twitch.twitch",
        "com.vimeo.vimeo"
    ]
    
    // Bekannte Bundle IDs für Gaming Apps
    static let gamingBundleIDs: [String] = [
        "com.supercell.clashofclans",
        "com.supercell.clashroyale",
        "com.king.candycrushsaga",
        "com.rovio.angrybirds",
        "com.epicgames.fortnite",
        "com.mojang.minecraftpe",
        "com.activision.callofduty.shooter"
    ]
    
    // URLs für Social Media
    static let socialMediaURLs: [String] = [
        "instagram.com",
        "facebook.com",
        "tiktok.com",
        "twitter.com",
        "x.com",
        "snapchat.com",
        "linkedin.com",
        "pinterest.com",
        "reddit.com",
        "discord.com"
    ]
    
    // URLs für Entertainment
    static let entertainmentURLs: [String] = [
        "youtube.com",
        "youtu.be",
        "netflix.com",
        "spotify.com",
        "twitch.tv",
        "vimeo.com",
        "hulu.com",
        "disney.com"
    ]
    
    // URLs für Gaming
    static let gamingURLs: [String] = [
        "steamcommunity.com",
        "epicgames.com",
        "battle.net"
    ]
    
    /// Erstellt Standard-Blocklisten
    static func createStandardBlockLists() -> [BlockList] {
        return [
            BlockList(
                id: "standard-social-media",
                name: "Social Media",
                appTokens: [], // Wird später über App-Picker gefüllt
                urls: socialMediaURLs,
                createdAt: Date(),
                updatedAt: Date(),
                isDefault: false
            ),
            BlockList(
                id: "standard-entertainment",
                name: "Unterhaltung",
                appTokens: [],
                urls: entertainmentURLs,
                createdAt: Date(),
                updatedAt: Date(),
                isDefault: false
            ),
            BlockList(
                id: "standard-gaming",
                name: "Gaming",
                appTokens: [],
                urls: gamingURLs,
                createdAt: Date(),
                updatedAt: Date(),
                isDefault: false
            ),
            BlockList(
                id: "standard-all-distractions",
                name: "Alle Ablenkungen",
                appTokens: [],
                urls: socialMediaURLs + entertainmentURLs + gamingURLs,
                createdAt: Date(),
                updatedAt: Date(),
                isDefault: false
            )
        ]
    }
}




