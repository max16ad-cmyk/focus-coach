//
//  FirebaseService.swift
//  FocusCoach
//
//  Firebase Integration - Simple & Robust
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private var db: Firestore?
    private var auth: Auth?
    private var storage: Storage?
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private var isConfigured = false
    
    private init() {
        // Empty init - configure later
    }
    
    // MARK: - Configuration
    
    func configure() {
        print("🔥🔥🔥 configure() START")
        fflush(stdout)
        
        // Prevent double configuration
        guard !isConfigured else {
            print("🔥 Firebase already configured")
            fflush(stdout)
            return
        }
        
        print("🔥🔥🔥 Checking FirebaseApp.app()")
        fflush(stdout)
        
        // Check if Firebase is already configured
        if FirebaseApp.app() != nil {
            print("🔥 Firebase app already exists")
            fflush(stdout)
            isConfigured = true
            initializeServices()
            return
        }
        
        print("🔥🔥🔥 Checking for plist file")
        fflush(stdout)
        
        // Check for plist file
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            print("🔥 ERROR: GoogleService-Info.plist not found!")
            fflush(stdout)
            return
        }
        
        print("🔥🔥🔥 About to call FirebaseApp.configure()")
        fflush(stdout)
        
        // Configure Firebase - this is synchronous and safe
        FirebaseApp.configure()
        
        print("🔥🔥🔥 FirebaseApp.configure() completed")
        fflush(stdout)
        
        isConfigured = true
        initializeServices()
        
        print("🔥🔥🔥 configure() COMPLETE")
        fflush(stdout)
    }
    
    private func initializeServices() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        
        // Setup auth state listener
        _ = auth?.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = User(id: user.uid, email: user.email ?? "")
                    self?.isAuthenticated = true
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Authentication
    
    func login(email: String, password: String) async throws {
        guard let auth = auth else { throw FirebaseError.notConfigured }
        let result = try await auth.signIn(withEmail: email, password: password)
        initializeUserData(userId: result.user.uid)
    }
    
    func register(email: String, password: String) async throws {
        guard let auth = auth else { throw FirebaseError.notConfigured }
        let result = try await auth.createUser(withEmail: email, password: password)
        initializeUserData(userId: result.user.uid)
    }
    
    func logout() async throws {
        guard let auth = auth else { throw FirebaseError.notConfigured }
        try auth.signOut()
    }
    
    // MARK: - User Data Initialization
    
    private func initializeUserData(userId: String) {
        guard let db = db else { return }
        
        let userRef = db.collection("users").document(userId)
        
        _Concurrency.Task {
            do {
                let document = try await userRef.getDocument()
                if !document.exists {
                    try await userRef.setData([
                        "stats": [
                            "xp": 0,
                            "level": 1,
                            "streak": 1,
                            "tasksCompleted": 0,
                            "penalties": 0
                        ],
                        "createdAt": Timestamp(date: Date()),
                        "lastActive": Timestamp(date: Date())
                    ])
                }
            } catch {
                print("Error initializing user data: \(error)")
            }
        }
    }
    
    // MARK: - Day Plans
    
    func saveDayPlan(_ plan: DayPlan) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let planRef = db.collection("users").document(userId)
            .collection("dayPlans").document(plan.date)
        
        let encoder = JSONEncoder()
        let planData = try encoder.encode(plan)
        guard let planDict = try JSONSerialization.jsonObject(with: planData) as? [String: Any] else {
            throw FirebaseError.invalidData
        }
        
        try await planRef.setData(planDict)
    }
    
    func getDayPlan(date: String) async throws -> DayPlan? {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let planRef = db.collection("users").document(userId)
            .collection("dayPlans").document(date)
        
        let document = try await planRef.getDocument()
        
        guard document.exists, let data = document.data() else {
            return nil
        }
        
        let convertedData = convertFirestoreData(data)
        let jsonData = try JSONSerialization.data(withJSONObject: convertedData)
        return try JSONDecoder().decode(DayPlan.self, from: jsonData)
    }
    
    func subscribeToDayPlan(date: String, completion: @escaping (DayPlan?) -> Void) -> ListenerRegistration? {
        guard let db = db, let userId = currentUser?.id else {
            completion(nil)
            return nil
        }
        
        let planRef = db.collection("users").document(userId)
            .collection("dayPlans").document(date)
        
        return planRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to day plan: \(error)")
                completion(nil)
                return
            }
            
            guard let document = snapshot, document.exists,
                  let data = document.data() else {
                completion(nil)
                return
            }
            
            do {
                let convertedData = self.convertFirestoreData(data)
                let jsonData = try JSONSerialization.data(withJSONObject: convertedData)
                let plan = try JSONDecoder().decode(DayPlan.self, from: jsonData)
                completion(plan)
            } catch {
                print("Error decoding day plan: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: - Settings
    
    func saveSettings(_ settings: UserSettings) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let userRef = db.collection("users").document(userId)
        
        let encoder = JSONEncoder()
        let settingsData = try encoder.encode(settings)
        guard let settingsDict = try JSONSerialization.jsonObject(with: settingsData) as? [String: Any] else {
            throw FirebaseError.invalidData
        }
        
        try await userRef.updateData([
            "settings": settingsDict,
            "lastActive": Timestamp(date: Date())
        ])
    }
    
    func getSettings() async throws -> UserSettings {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let userRef = db.collection("users").document(userId)
        let document = try await userRef.getDocument()
        
        guard let data = document.data(),
              let settingsData = data["settings"] as? [String: Any] else {
            return UserSettings.default
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: settingsData)
        return try JSONDecoder().decode(UserSettings.self, from: jsonData)
    }
    
    func subscribeToSettings(completion: @escaping (UserSettings) -> Void) -> ListenerRegistration? {
        guard let db = db, let userId = currentUser?.id else {
            completion(UserSettings.default)
            return nil
        }
        
        let userRef = db.collection("users").document(userId)
        
        return userRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to settings: \(error)")
                completion(UserSettings.default)
                return
            }
            
            guard let document = snapshot, document.exists,
                  let data = document.data(),
                  let settingsData = data["settings"] as? [String: Any] else {
                completion(UserSettings.default)
                return
            }
            
            do {
                let convertedData = self.convertFirestoreData(settingsData)
                let jsonData = try JSONSerialization.data(withJSONObject: convertedData)
                let settings = try JSONDecoder().decode(UserSettings.self, from: jsonData)
                completion(settings)
            } catch {
                print("Error decoding settings: \(error)")
                completion(UserSettings.default)
            }
        }
    }
    
    // MARK: - BlockLists
    
    /// Speichert eine Blockliste in Firebase
    func saveBlockList(_ blockList: BlockList) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let blockListRef = db.collection("users").document(userId)
            .collection("blockLists").document(blockList.id)
        
        // Konvertiere BlockList zu Dictionary
        // WICHTIG: ApplicationTokens können nicht direkt gespeichert werden
        // Speichere nur URLs und Multi-Platform Identifiers
        var blockListDict: [String: Any] = [
            "id": blockList.id,
            "name": blockList.name,
            "urls": blockList.urls,
            "createdAt": Timestamp(date: blockList.createdAt),
            "updatedAt": Timestamp(date: blockList.updatedAt),
            "isDefault": blockList.isDefault
        ]
        
        // Speichere Multi-Platform App Identifiers
        if let appIdentifiers = blockList.appIdentifiers {
            blockListDict["appIdentifiers"] = [
                "ios": appIdentifiers.ios,
                "macos": appIdentifiers.macos,
                "windows": appIdentifiers.windows,
                "web": appIdentifiers.web
            ]
        }
        
        // Speichere FamilyActivitySelection Data (falls vorhanden)
        if let selectionData = blockList.familyActivitySelectionData {
            blockListDict["familyActivitySelectionData"] = selectionData.base64EncodedString()
        }
        
        try await blockListRef.setData(blockListDict, merge: true)
        print("✅ FirebaseService: Blockliste '\(blockList.name)' gespeichert")
    }
    
    /// Lädt alle Blocklisten aus Firebase
    func getAllBlockLists() async throws -> [BlockList] {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let blockListsRef = db.collection("users").document(userId)
            .collection("blockLists")
        
        let snapshot = try await blockListsRef.getDocuments()
        var blockLists: [BlockList] = []
        
        for document in snapshot.documents {
            do {
                let data = document.data()
                let convertedData = self.convertFirestoreData(data)
                
                // Konvertiere zu BlockList
                var blockList = BlockList(
                    id: convertedData["id"] as? String ?? document.documentID,
                    name: convertedData["name"] as? String ?? "Unbekannt",
                    urls: convertedData["urls"] as? [String] ?? [],
                    createdAt: (convertedData["createdAt"] as? Int64).flatMap { Date(timeIntervalSince1970: TimeInterval($0) / 1000) } ?? Date(),
                    updatedAt: (convertedData["updatedAt"] as? Int64).flatMap { Date(timeIntervalSince1970: TimeInterval($0) / 1000) } ?? Date(),
                    isDefault: convertedData["isDefault"] as? Bool ?? false
                )
                
                // Lade Multi-Platform App Identifiers
                if let identifiersDict = convertedData["appIdentifiers"] as? [String: Any] {
                    blockList.appIdentifiers = MultiPlatformAppIdentifiers(
                        ios: identifiersDict["ios"] as? [String] ?? [],
                        macos: identifiersDict["macos"] as? [String] ?? [],
                        windows: identifiersDict["windows"] as? [String] ?? [],
                        web: identifiersDict["web"] as? [String] ?? []
                    )
                }
                
                // Lade FamilyActivitySelection Data
                if let selectionDataString = convertedData["familyActivitySelectionData"] as? String,
                   let selectionData = Data(base64Encoded: selectionDataString) {
                    blockList.familyActivitySelectionData = selectionData
                }
                
                blockLists.append(blockList)
            } catch {
                print("⚠️ FirebaseService: Fehler beim Laden der Blockliste \(document.documentID): \(error)")
            }
        }
        
        return blockLists
    }
    
    /// Abonniert Blocklisten-Änderungen in Echtzeit
    func subscribeToBlockLists(completion: @escaping ([BlockList]) -> Void) -> ListenerRegistration? {
        guard let db = db, let userId = currentUser?.id else {
            completion([])
            return nil
        }
        
        let blockListsRef = db.collection("users").document(userId)
            .collection("blockLists")
        
        return blockListsRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("⚠️ FirebaseService: Fehler beim Abonnieren von Blocklisten: \(error)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            var blockLists: [BlockList] = []
            
            for document in documents {
                do {
                    let data = document.data()
                    let convertedData = self.convertFirestoreData(data)
                    
                    // Konvertiere zu BlockList
                    var blockList = BlockList(
                        id: convertedData["id"] as? String ?? document.documentID,
                        name: convertedData["name"] as? String ?? "Unbekannt",
                        urls: convertedData["urls"] as? [String] ?? [],
                        createdAt: (convertedData["createdAt"] as? Int64).flatMap { Date(timeIntervalSince1970: TimeInterval($0) / 1000) } ?? Date(),
                        updatedAt: (convertedData["updatedAt"] as? Int64).flatMap { Date(timeIntervalSince1970: TimeInterval($0) / 1000) } ?? Date(),
                        isDefault: convertedData["isDefault"] as? Bool ?? false
                    )
                    
                    // Lade Multi-Platform App Identifiers
                    if let identifiersDict = convertedData["appIdentifiers"] as? [String: Any] {
                        blockList.appIdentifiers = MultiPlatformAppIdentifiers(
                            ios: identifiersDict["ios"] as? [String] ?? [],
                            macos: identifiersDict["macos"] as? [String] ?? [],
                            windows: identifiersDict["windows"] as? [String] ?? [],
                            web: identifiersDict["web"] as? [String] ?? []
                        )
                    }
                    
                    // Lade FamilyActivitySelection Data
                    if let selectionDataString = convertedData["familyActivitySelectionData"] as? String,
                       let selectionData = Data(base64Encoded: selectionDataString) {
                        blockList.familyActivitySelectionData = selectionData
                    }
                    
                    blockLists.append(blockList)
                } catch {
                    print("⚠️ FirebaseService: Fehler beim Dekodieren der Blockliste \(document.documentID): \(error)")
                }
            }
            
            completion(blockLists)
        }
    }
    
    /// Löscht eine Blockliste aus Firebase
    func deleteBlockList(_ blockListId: String) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let blockListRef = db.collection("users").document(userId)
            .collection("blockLists").document(blockListId)
        
        try await blockListRef.delete()
        print("✅ FirebaseService: Blockliste \(blockListId) gelöscht")
    }
    
    // MARK: - Photo Upload
    
    func uploadProofImage(_ imageData: Data, taskId: String) async throws -> String {
        guard let storage = storage else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let imageRef = storage.reference()
            .child("users/\(userId)/proofs/\(taskId).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await imageRef.putData(imageData, metadata: metadata)
        let url = try await imageRef.downloadURL()
        
        return url.absoluteString
    }
    
    // MARK: - Tasks (Central Task Management)
    
    /// Speichert eine Task zentral (nicht in DayPlan)
    func saveTask(_ task: Task) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let taskRef = db.collection("users").document(userId)
            .collection("tasks").document(task.id)
        
        let encoder = JSONEncoder()
        let taskData = try encoder.encode(task)
        guard var taskDict = try JSONSerialization.jsonObject(with: taskData) as? [String: Any] else {
            throw FirebaseError.invalidData
        }
        
        // Ensure createdAt is set if not present
        if taskDict["createdAt"] == nil {
            taskDict["createdAt"] = Timestamp(date: Date())
        }
        
        try await taskRef.setData(taskDict, merge: true)
    }
    
    /// Lädt alle Tasks für einen User
    func getAllTasks() async throws -> [Task] {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let tasksRef = db.collection("users").document(userId).collection("tasks")
        let querySnapshot = try await tasksRef.getDocuments()
        
        var tasks: [Task] = []
        for document in querySnapshot.documents {
            do {
                let data = document.data()
                let convertedData = convertFirestoreData(data)
                let jsonData = try JSONSerialization.data(withJSONObject: convertedData)
                var task = try JSONDecoder().decode(Task.self, from: jsonData)
                tasks.append(task)
            } catch {
                print("⚠️ Error decoding task \(document.documentID): \(error)")
            }
        }
        
        return tasks
    }
    
    /// Aktualisiert eine Task
    func updateTask(_ task: Task) async throws {
        try await saveTask(task) // Same implementation
    }
    
    /// Löscht eine Task
    func deleteTask(_ taskId: String) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let taskRef = db.collection("users").document(userId)
            .collection("tasks").document(taskId)
        
        try await taskRef.delete()
    }
    
    /// Real-time Subscription für alle Tasks
    func subscribeToTasks(completion: @escaping ([Task]) -> Void) -> ListenerRegistration? {
        guard let db = db, let userId = currentUser?.id else {
            completion([])
            return nil
        }
        
        let tasksRef = db.collection("users").document(userId).collection("tasks")
        
        return tasksRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to tasks: \(error)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            var tasks: [Task] = []
            for document in documents {
                do {
                    let data = document.data()
                    // Konvertiere FIRTimestamp zu Int64 (Millisekunden)
                    let convertedData = self.convertFirestoreData(data)
                    let jsonData = try JSONSerialization.data(withJSONObject: convertedData)
                    var task = try JSONDecoder().decode(Task.self, from: jsonData)
                    tasks.append(task)
                } catch {
                    print("⚠️ Error decoding task \(document.documentID): \(error)")
                }
            }
            
            completion(tasks)
        }
    }
    
    // MARK: - Routines
    
    func saveRoutine(_ routine: Routine) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let routineRef = db.collection("users").document(userId)
            .collection("routines").document(routine.id)
        
        let encoder = JSONEncoder()
        let routineData = try encoder.encode(routine)
        guard var routineDict = try JSONSerialization.jsonObject(with: routineData) as? [String: Any] else {
            throw FirebaseError.invalidData
        }
        
        // Ensure timestamps are set
        if routineDict["createdAt"] == nil {
            routineDict["createdAt"] = Timestamp(date: Date())
        }
        routineDict["updatedAt"] = Timestamp(date: Date())
        
        // Logging für Debugging
        print("💾 FirebaseService.saveRoutine: Speichere Routine '\(routine.name)'")
        print("   - repeatPattern: \(routine.repeatPattern.rawValue)")
        if let weekdays = routine.repeatWeekdays {
            print("   - repeatWeekdays: Mo=\(weekdays.monday), Di=\(weekdays.tuesday), Mi=\(weekdays.wednesday), Do=\(weekdays.thursday), Fr=\(weekdays.friday), Sa=\(weekdays.saturday), So=\(weekdays.sunday)")
            print("   - repeatWeekdays JSON: \(String(data: try! JSONEncoder().encode(weekdays), encoding: .utf8) ?? "nil")")
        } else {
            print("   - repeatWeekdays: nil")
        }
        
        // WICHTIG: Verwende setData OHNE merge, damit nil-Werte auch gespeichert werden
        // Oder verwende merge: false und setze explizit alle Felder
        try await routineRef.setData(routineDict, merge: false)
    }
    
    func deleteRoutine(_ routineId: String) async throws {
        guard let db = db else { throw FirebaseError.notConfigured }
        guard let userId = currentUser?.id else { throw FirebaseError.notAuthenticated }
        
        let routineRef = db.collection("users").document(userId)
            .collection("routines").document(routineId)
        
        try await routineRef.delete()
    }
    
    func subscribeToRoutines(completion: @escaping ([Routine]) -> Void) -> ListenerRegistration? {
        guard let db = db, let userId = currentUser?.id else {
            completion([])
            return nil
        }
        
        let routinesRef = db.collection("users").document(userId).collection("routines")
        
        return routinesRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to routines: \(error)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            var routines: [Routine] = []
            let decoder = JSONDecoder()
            
            for document in documents {
                do {
                    let data = document.data()
                    // Logging für Debugging
                    print("📖 FirebaseService.subscribeToRoutines: Lade Routine \(document.documentID)")
                    if let repeatWeekdaysData = data["repeatWeekdays"] as? [String: Any] {
                        print("   - repeatWeekdays in Firebase: \(repeatWeekdaysData)")
                    } else {
                        print("   - repeatWeekdays in Firebase: nil oder nicht vorhanden")
                    }
                    
                    // Konvertiere FIRTimestamp zu Int64 (Millisekunden)
                    let convertedData = self.convertFirestoreData(data)
                    let jsonData = try JSONSerialization.data(withJSONObject: convertedData)
                    var routine = try decoder.decode(Routine.self, from: jsonData)
                    
                    print("   - Routine '\(routine.name)' dekodiert")
                    print("   - repeatPattern: \(routine.repeatPattern.rawValue)")
                    if let weekdays = routine.repeatWeekdays {
                        print("   - repeatWeekdays dekodiert: Mo=\(weekdays.monday), Di=\(weekdays.tuesday), Mi=\(weekdays.wednesday), Do=\(weekdays.thursday), Fr=\(weekdays.friday), Sa=\(weekdays.saturday), So=\(weekdays.sunday)")
                    } else {
                        print("   - repeatWeekdays dekodiert: nil")
                    }
                    
                    routines.append(routine)
                } catch {
                    print("⚠️ Error decoding routine \(document.documentID): \(error)")
                    print("   - Error details: \(error.localizedDescription)")
                }
            }
            
            completion(routines)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Konvertiert Firestore-Daten (FIRTimestamp, etc.) zu JSON-serialisierbaren Typen
    private func convertFirestoreData(_ data: [String: Any]) -> [String: Any] {
        var converted: [String: Any] = [:]
        
        for (key, value) in data {
            if let timestamp = value as? Timestamp {
                // Konvertiere FIRTimestamp zu Int64 (Millisekunden seit 1970)
                let milliseconds = Int64(timestamp.dateValue().timeIntervalSince1970 * 1000)
                converted[key] = milliseconds
            } else if let dict = value as? [String: Any] {
                // Rekursiv für verschachtelte Dictionaries
                converted[key] = convertFirestoreData(dict)
            } else if let array = value as? [Any] {
                // Konvertiere Arrays rekursiv
                converted[key] = array.map { item -> Any in
                    if let dict = item as? [String: Any] {
                        return convertFirestoreData(dict)
                    } else if let timestamp = item as? Timestamp {
                        return Int64(timestamp.dateValue().timeIntervalSince1970 * 1000)
                    }
                    return item
                }
            } else {
                // Andere Typen bleiben unverändert
                converted[key] = value
            }
        }
        
        return converted
    }
}

// MARK: - Errors

enum FirebaseError: LocalizedError {
    case notConfigured
    case notAuthenticated
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Firebase is not configured"
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidData:
            return "Invalid data"
        }
    }
}
