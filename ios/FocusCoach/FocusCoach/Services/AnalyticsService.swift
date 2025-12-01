//
//  AnalyticsService.swift
//  FocusCoach
//
//  Cross-Platform Analytics Service
//

import Foundation
import FirebaseFirestore
import Combine

enum Platform: String, Codable {
    case ios
    case macos
    case windows
    case web
}

enum ActivityEvent: String, Codable {
    case appBlocked = "app_blocked"
    case appUnblocked = "app_unblocked"
    case urlBlocked = "url_blocked"
    case urlUnblocked = "url_unblocked"
    case taskCompleted = "task_completed"
    case taskCreated = "task_created"
    case taskStarted = "task_started"
    case routineCompleted = "routine_completed"
    case screenTimeAnalyzed = "screen_time_analyzed"
    case blocklistUpdated = "blocklist_updated"
}

struct ActivityLog: Codable {
    let id: String?
    let platform: Platform
    let timestamp: Date
    let event: ActivityEvent
    let data: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case id
        case platform
        case timestamp
        case event
        case data
    }
    
    init(id: String? = nil, platform: Platform, timestamp: Date = Date(), event: ActivityEvent, data: [String: Any] = [:]) {
        self.id = id
        self.platform = platform
        self.timestamp = timestamp
        self.event = event
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decodeIfPresent(String.self, forKey: .id)
        platform = try container.decode(Platform.self, forKey: .platform)
        
        // Decode timestamp
        if let timestampValue = try? container.decode(Timestamp.self, forKey: .timestamp) {
            timestamp = timestampValue.dateValue()
        } else {
            timestamp = Date()
        }
        
        event = try container.decode(ActivityEvent.self, forKey: .event)
        
        // Decode data dictionary
        if let dataDict = try? container.decode([String: AnyCodable].self, forKey: .data) {
            data = dataDict.mapValues { $0.value }
        } else {
            data = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(platform, forKey: .platform)
        try container.encode(Timestamp(date: timestamp), forKey: .timestamp)
        try container.encode(event, forKey: .event)
        
        // Encode data dictionary
        let codableData = data.mapValues { AnyCodable($0) }
        try container.encode(codableData, forKey: .data)
    }
}

// Helper for encoding/decoding Any values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        }
    }
}

@MainActor
class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    private let firebaseService = FirebaseService.shared
    private var listener: ListenerRegistration?
    
    private init() {}
    
    /// Log an activity to Firebase
    func logActivity(
        platform: Platform,
        event: ActivityEvent,
        data: [String: Any] = [:]
    ) {
        guard let userId = firebaseService.currentUser?.id else {
            print("⚠️ AnalyticsService: Cannot log activity - not authenticated")
            return
        }
        
        let activity = ActivityLog(
            platform: platform,
            timestamp: Date(),
            event: event,
            data: data
        )
        
        _Concurrency.Task {
            do {
                guard let db = firebaseService.db else {
                    print("⚠️ AnalyticsService: Firebase not configured")
                    return
                }
                
                let activitiesRef = db.collection("users").document(userId)
                    .collection("activities")
                
                // Convert ActivityLog to Firestore-compatible format
                var activityData: [String: Any] = [
                    "platform": platform.rawValue,
                    "timestamp": Timestamp(date: activity.timestamp),
                    "event": event.rawValue
                ]
                
                // Add data dictionary
                for (key, value) in data {
                    activityData["data.\(key)"] = value
                }
                
                // Store as nested data
                activityData["data"] = data
                
                try await activitiesRef.addDocument(data: activityData)
                print("✅ AnalyticsService: Logged \(event.rawValue) on \(platform.rawValue)")
            } catch {
                print("⚠️ AnalyticsService: Error logging activity: \(error)")
            }
        }
    }
    
    /// Get activities for a date range
    func getActivitiesForDateRange(
        startDate: Date,
        endDate: Date
    ) async throws -> [ActivityLog] {
        guard let userId = firebaseService.currentUser?.id else {
            throw NSError(domain: "AnalyticsService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        guard let db = firebaseService.db else {
            throw NSError(domain: "AnalyticsService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Firebase not configured"])
        }
        
        let activitiesRef = db.collection("users").document(userId)
            .collection("activities")
        
        let query = activitiesRef
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("timestamp", isLessThanOrEqualTo: Timestamp(date: endDate))
        
        let snapshot = try await query.getDocuments()
        var activities: [ActivityLog] = []
        
        for document in snapshot.documents {
            do {
                let data = document.data()
                let platform = Platform(rawValue: data["platform"] as? String ?? "ios") ?? .ios
                let event = ActivityEvent(rawValue: data["event"] as? String ?? "") ?? .taskCreated
                
                let timestamp: Date
                if let ts = data["timestamp"] as? Timestamp {
                    timestamp = ts.dateValue()
                } else {
                    timestamp = Date()
                }
                
                let activityData = data["data"] as? [String: Any] ?? [:]
                
                activities.append(ActivityLog(
                    id: document.documentID,
                    platform: platform,
                    timestamp: timestamp,
                    event: event,
                    data: activityData
                ))
            } catch {
                print("⚠️ AnalyticsService: Error decoding activity: \(error)")
            }
        }
        
        return activities.sorted { $0.timestamp > $1.timestamp }
    }
    
    /// Get daily analytics summary
    func getDailyAnalytics(date: Date = Date()) async throws -> AnalyticsSummary {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
        
        let activities = try await getActivitiesForDateRange(startDate: startOfDay, endDate: endOfDay)
        return calculateAnalyticsSummary(activities)
    }
    
    /// Calculate analytics summary from activities
    private func calculateAnalyticsSummary(_ activities: [ActivityLog]) -> AnalyticsSummary {
        // Group by platform
        let byPlatform = (
            ios: activities.filter { $0.platform == .ios },
            macos: activities.filter { $0.platform == .macos },
            windows: activities.filter { $0.platform == .windows }
        )
        
        // Calculate total screen time
        let blockedAppEvents = activities.filter { 
            $0.event == .appBlocked && ($0.data["duration"] as? Int) != nil
        }
        let totalScreenTime = blockedAppEvents.reduce(0) { sum, event in
            sum + (event.data["duration"] as? Int ?? 0)
        }
        
        // Get blocked apps by platform
        let blockedApps = (
            ios: Array(Set(byPlatform.ios
                .filter { $0.event == .appBlocked }
                .compactMap { $0.data["appName"] as? String })),
            macos: Array(Set(byPlatform.macos
                .filter { $0.event == .appBlocked }
                .compactMap { $0.data["appName"] as? String })),
            windows: Array(Set(byPlatform.windows
                .filter { $0.event == .appBlocked }
                .compactMap { $0.data["appName"] as? String }))
        )
        
        // Count completed tasks
        let completedTasks = activities.filter { $0.event == .taskCompleted }.count
        
        // Calculate productivity score
        let productiveTime = activities
            .filter { $0.event == .taskCompleted }
            .reduce(0) { sum, activity in
                sum + (activity.data["duration"] as? Int ?? 0)
            }
        
        let distractedTime = totalScreenTime - productiveTime
        let productivityScore = totalScreenTime > 0
            ? Int(round(Double(productiveTime) / Double(totalScreenTime) * 100))
            : 0
        
        return AnalyticsSummary(
            totalScreenTime: totalScreenTime,
            blockedApps: blockedApps,
            completedTasks: completedTasks,
            productivityScore: productivityScore,
            timeDistribution: (
                productive: productiveTime,
                distracted: distractedTime
            ),
            byPlatform: byPlatform
        )
    }
}

struct AnalyticsSummary {
    let totalScreenTime: Int // in seconds
    let blockedApps: (ios: [String], macos: [String], windows: [String])
    let completedTasks: Int
    let productivityScore: Int // 0-100
    let timeDistribution: (productive: Int, distracted: Int)
    let byPlatform: (ios: [ActivityLog], macos: [ActivityLog], windows: [ActivityLog])
}



