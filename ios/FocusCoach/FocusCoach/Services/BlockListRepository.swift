//
//  BlockListRepository.swift
//  FocusCoach
//
//  Repository für Blocklisten-Verwaltung
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings
import FirebaseFirestore

@MainActor
class BlockListRepository: ObservableObject {
    static let shared = BlockListRepository()
    
    @Published var blockLists: [BlockList] = []
    @Published var defaultBlockList: BlockList?
    
    private let userDefaultsKey = "blockLists"
    private let defaultBlockListKey = "defaultBlockList"
    private let firebaseService = FirebaseService.shared
    private var firebaseListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Lade lokal gespeicherte Blocklisten
        loadBlockLists()
        ensureDefaultBlockList()
        ensureStandardBlockLists()
        
        // Starte Firebase-Sync wenn authentifiziert
        firebaseService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.startFirebaseSync()
                } else {
                    self?.stopFirebaseSync()
                }
            }
            .store(in: &cancellables)
        
        // Starte Sync wenn bereits authentifiziert
        if firebaseService.isAuthenticated {
            startFirebaseSync()
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Lädt alle Blocklisten aus UserDefaults
    func loadBlockLists() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([BlockList].self, from: data) else {
            // Erstelle Standard-Blockliste wenn keine vorhanden
            createDefaultBlockList()
            return
        }
        
        blockLists = decoded
        
        // Lade ApplicationTokens für jede Blockliste
        for (index, blockList) in blockLists.enumerated() {
            // Versuche zuerst FamilyActivitySelection zu laden
            if let selectionData = blockList.familyActivitySelectionData,
               let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData) {
                blockLists[index].appTokens = selection.applicationTokens
                print("📖 BlockListRepository: Lade \(selection.applicationTokens.count) Apps für Blockliste '\(blockList.name)' aus familyActivitySelectionData")
            } else if let data = UserDefaults.standard.data(forKey: "blockList_\(blockList.id)_selection"),
                      let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                blockLists[index].appTokens = selection.applicationTokens
                blockLists[index].familyActivitySelectionData = data
                print("📖 BlockListRepository: Lade \(selection.applicationTokens.count) Apps für Blockliste '\(blockList.name)' aus UserDefaults")
            } else if let tokens = loadAppTokens(for: blockList.id) {
                blockLists[index].appTokens = tokens
                print("📖 BlockListRepository: Lade \(tokens.count) Apps für Blockliste '\(blockList.name)' aus loadAppTokens")
            } else {
                // FALLBACK: Für Standard-Blockliste, versuche BlockingService zu verwenden
                if blockList.isDefault || blockList.id == defaultBlockList?.id {
                    let blockingService = BlockingService.shared
                    if !blockingService.familyActivitySelection.applicationTokens.isEmpty {
                        blockLists[index].appTokens = blockingService.familyActivitySelection.applicationTokens
                        print("📖 BlockListRepository: Fallback - Lade \(blockingService.familyActivitySelection.applicationTokens.count) Apps für Standard-Blockliste '\(blockList.name)' aus BlockingService")
                    } else {
                        print("⚠️ BlockListRepository: Keine Apps gefunden für Blockliste '\(blockList.name)'")
                    }
                } else {
                    print("⚠️ BlockListRepository: Keine Apps gefunden für Blockliste '\(blockList.name)'")
                }
            }
        }
        
        // Lade Standard-Blockliste
        if let defaultId = UserDefaults.standard.string(forKey: defaultBlockListKey),
           let defaultList = blockLists.first(where: { $0.id == defaultId }) {
            defaultBlockList = defaultList
        } else {
            // Setze erste Blockliste als Standard
            if let first = blockLists.first {
                setDefaultBlockList(first)
            }
        }
    }
    
    /// Speichert alle Blocklisten in UserDefaults und Firebase
    func saveBlockLists() {
        // Speichere Blocklisten lokal (ohne ApplicationTokens - werden separat gespeichert)
        if let encoded = try? JSONEncoder().encode(blockLists) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        
        // Speichere ApplicationTokens separat für jede Blockliste
        for blockList in blockLists {
            saveAppTokens(blockList.appTokens, for: blockList.id)
        }
        
        // Speichere Standard-Blockliste ID
        if let defaultId = defaultBlockList?.id {
            UserDefaults.standard.set(defaultId, forKey: defaultBlockListKey)
        }
        
        // Synchronisiere mit Firebase (wenn authentifiziert)
        if firebaseService.isAuthenticated {
            syncToFirebase()
        }
    }
    
    /// Synchronisiert alle Blocklisten zu Firebase
    private func syncToFirebase() {
        _Concurrency.Task {
            for blockList in blockLists {
                do {
                    // Aktualisiere Multi-Platform Identifiers vor dem Speichern
                    var updatedBlockList = blockList
                    
                    // Konvertiere ApplicationTokens zu Bundle IDs (falls möglich)
                    if updatedBlockList.appIdentifiers == nil && !blockList.appTokens.isEmpty {
                        // Extrahiere Bundle IDs aus FamilyActivitySelection
                        if blockList.loadFamilyActivitySelection() != nil {
                            // Für jetzt: Verwende leere Identifiers, wird später über App-Mapping gelöst
                            updatedBlockList.appIdentifiers = MultiPlatformAppIdentifiers()
                        }
                    }
                    
                    // Konvertiere URLs zu Web-Identifiers
                    if updatedBlockList.appIdentifiers == nil {
                        updatedBlockList.appIdentifiers = MultiPlatformAppIdentifiers()
                    }
                    updatedBlockList.appIdentifiers?.web = updatedBlockList.urls
                    
                    try await firebaseService.saveBlockList(updatedBlockList)
                } catch {
                    print("⚠️ BlockListRepository: Fehler beim Synchronisieren von Blockliste '\(blockList.name)': \(error)")
                }
            }
        }
    }
    
    /// Startet Firebase Real-time Sync
    private func startFirebaseSync() {
        guard firebaseListener == nil else { return }
        
        firebaseListener = firebaseService.subscribeToBlockLists { [weak self] firebaseBlockLists in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                print("📥 BlockListRepository: Empfange \(firebaseBlockLists.count) Blocklisten von Firebase")
                
                // Merge Firebase Blocklisten mit lokalen
                // Firebase hat Priorität für URLs und Multi-Platform Identifiers
                // Lokale ApplicationTokens bleiben erhalten
                
                for firebaseList in firebaseBlockLists {
                    if let localIndex = self.blockLists.firstIndex(where: { $0.id == firebaseList.id }) {
                        // Merge: Behalte lokale ApplicationTokens, verwende Firebase URLs und Identifiers
                        var merged = self.blockLists[localIndex]
                        merged.urls = firebaseList.urls
                        merged.appIdentifiers = firebaseList.appIdentifiers
                        merged.name = firebaseList.name
                        merged.isDefault = firebaseList.isDefault
                        merged.updatedAt = firebaseList.updatedAt
                        
                        // Behalte lokale FamilyActivitySelection wenn vorhanden
                        if merged.familyActivitySelectionData == nil {
                            merged.familyActivitySelectionData = firebaseList.familyActivitySelectionData
                        }
                        
                        self.blockLists[localIndex] = merged
                    } else {
                        // Neue Blockliste von Firebase
                        self.blockLists.append(firebaseList)
                    }
                }
                
                // Aktualisiere Standard-Blockliste
                if let defaultId = UserDefaults.standard.string(forKey: self.defaultBlockListKey),
                   let defaultList = self.blockLists.first(where: { $0.id == defaultId }) {
                    self.defaultBlockList = defaultList
                }
                
                // Speichere lokal
                self.saveBlockLists()
            }
        }
        
        print("✅ BlockListRepository: Firebase Sync gestartet")
    }
    
    /// Stoppt Firebase Sync
    private func stopFirebaseSync() {
        firebaseListener?.remove()
        firebaseListener = nil
        print("🛑 BlockListRepository: Firebase Sync gestoppt")
    }
    
    /// Erstellt eine neue Blockliste
    func createBlockList(name: String, appTokens: Set<ApplicationToken> = [], urls: [String] = []) -> BlockList {
        let blockList = BlockList(
            name: name,
            appTokens: appTokens,
            urls: urls
        )
        
        blockLists.append(blockList)
        saveBlockLists()
        
        return blockList
    }
    
    /// Aktualisiert eine Blockliste
    func updateBlockList(_ blockList: BlockList) {
        guard let index = blockLists.firstIndex(where: { $0.id == blockList.id }) else {
            return
        }
        
        var updated = blockList
        updated.updatedAt = Date()
        
        // Aktualisiere Multi-Platform Identifiers wenn ApplicationTokens vorhanden
        if updated.appIdentifiers == nil && !updated.appTokens.isEmpty {
            // Versuche Bundle IDs zu extrahieren (wird später über App-Mapping gelöst)
            updated.appIdentifiers = MultiPlatformAppIdentifiers()
        }
        
        // Speichere ApplicationTokens separat
        saveAppTokens(updated.appTokens, for: updated.id)
        
        blockLists[index] = updated
        
        saveBlockLists()
        
        // Update defaultBlockList wenn nötig
        if defaultBlockList?.id == blockList.id {
            defaultBlockList = updated
        }
    }
    
    /// Aktualisiert ApplicationTokens für eine Blockliste
    func updateAppTokens(_ tokens: Set<ApplicationToken>, for blockListId: String) {
        guard let index = blockLists.firstIndex(where: { $0.id == blockListId }) else {
            return
        }
        
        blockLists[index].appTokens = tokens
        saveAppTokens(tokens, for: blockListId)
        saveBlockLists()
        
        // Update defaultBlockList wenn nötig
        if defaultBlockList?.id == blockListId {
            defaultBlockList = blockLists[index]
        }
    }
    
    /// Aktualisiert URLs für eine Blockliste
    func updateURLs(_ urls: [String], for blockListId: String) {
        guard let index = blockLists.firstIndex(where: { $0.id == blockListId }) else {
            return
        }
        
        blockLists[index].urls = urls
        blockLists[index].updatedAt = Date()
        saveBlockLists()
        
        // Update defaultBlockList wenn nötig
        if defaultBlockList?.id == blockListId {
            defaultBlockList = blockLists[index]
        }
    }
    
    /// Löscht eine Blockliste
    func deleteBlockList(_ blockList: BlockList) {
        // Verhindere Löschung der Standard-Blockliste
        if blockList.isDefault {
            print("⚠️ BlockListRepository: Kann Standard-Blockliste nicht löschen")
            return
        }
        
        blockLists.removeAll { $0.id == blockList.id }
        
        // Lösche gespeicherte ApplicationTokens
        UserDefaults.standard.removeObject(forKey: "blockList_\(blockList.id)_tokens")
        
        saveBlockLists()
    }
    
    /// Setzt eine Blockliste als Standard
    func setDefaultBlockList(_ blockList: BlockList) {
        // Entferne isDefault von allen anderen
        for (index, list) in blockLists.enumerated() {
            blockLists[index].isDefault = (list.id == blockList.id)
        }
        
        defaultBlockList = blockList
        saveBlockLists()
    }
    
    /// Gibt Blockliste für ID zurück
    func getBlockList(id: String) -> BlockList? {
        return blockLists.first { $0.id == id }
    }
    
    // MARK: - ApplicationTokens Storage
    
    /// Speichert ApplicationTokens für eine Blockliste
    /// Note: ApplicationToken ist nicht direkt Codable, daher speichern wir über FamilyActivitySelection
    private func saveAppTokens(_ tokens: Set<ApplicationToken>, for blockListId: String) {
        // Erstelle eine FamilyActivitySelection mit den Tokens
        // Da FamilyActivitySelection nicht direkt modifiziert werden kann,
        // speichern wir die Tokens über BlockingService.storeSelection()
        // Für jetzt: Speichere die Tokens als separate FamilyActivitySelection
        // Die Tokens werden über BlockingService verwaltet
        
        // Alternative: Speichere die Tokens direkt als Set (wenn möglich)
        // Da ApplicationToken nicht Codable ist, müssen wir einen Workaround verwenden
        // Wir speichern die Tokens über eine temporäre FamilyActivitySelection
        // und laden sie später wieder
        
        // Für jetzt: Tokens werden in BlockList.appTokens gespeichert (in-memory)
        // und müssen über BlockingService verwaltet werden
        print("💾 BlockListRepository: Speichere \(tokens.count) ApplicationTokens für Blockliste \(blockListId)")
    }
    
    /// Lädt ApplicationTokens für eine Blockliste
    private func loadAppTokens(for blockListId: String) -> Set<ApplicationToken>? {
        // Lade FamilyActivitySelection für diese Blockliste
        guard let data = UserDefaults.standard.data(forKey: "blockList_\(blockListId)_selection") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let selection = try decoder.decode(FamilyActivitySelection.self, from: data)
            return selection.applicationTokens
        } catch {
            print("⚠️ BlockListRepository: Fehler beim Laden der ApplicationTokens: \(error)")
            return nil
        }
    }
    
    /// Speichert ApplicationTokens über FamilyActivitySelection
    func saveAppTokensViaSelection(_ selection: FamilyActivitySelection, for blockListId: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(selection)
            UserDefaults.standard.set(data, forKey: "blockList_\(blockListId)_selection")
            UserDefaults.standard.synchronize()
            
            // Update in-memory BlockList
            if let index = blockLists.firstIndex(where: { $0.id == blockListId }) {
                blockLists[index].appTokens = selection.applicationTokens
                blockLists[index].familyActivitySelectionData = data
            }
        } catch {
            print("⚠️ BlockListRepository: Fehler beim Speichern der ApplicationTokens: \(error)")
        }
    }
    
    /// Aktualisiert BlockList mit FamilyActivitySelection
    func updateBlockListWithSelection(_ blockListId: String, selection: FamilyActivitySelection) {
        guard let index = blockLists.firstIndex(where: { $0.id == blockListId }) else {
            print("⚠️ BlockListRepository: Blockliste mit ID \(blockListId) nicht gefunden")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(selection)
            
            // WICHTIG: Aktualisiere appTokens aus der Selection
            blockLists[index].appTokens = selection.applicationTokens
            blockLists[index].familyActivitySelectionData = data
            blockLists[index].updatedAt = Date()
            
            // Speichere auch separat für schnellen Zugriff
            UserDefaults.standard.set(data, forKey: "blockList_\(blockListId)_selection")
            UserDefaults.standard.synchronize()
            
            print("💾 BlockListRepository: Speichere \(selection.applicationTokens.count) Apps für Blockliste '\(blockLists[index].name)'")
            
            saveBlockLists()
            
            // Update defaultBlockList wenn nötig
            if defaultBlockList?.id == blockListId {
                defaultBlockList = blockLists[index]
            }
        } catch {
            print("⚠️ BlockListRepository: Fehler beim Aktualisieren der Selection: \(error)")
        }
    }
    
    // MARK: - Default BlockList
    
    /// Erstellt Standard-Blockliste wenn keine vorhanden
    private func ensureDefaultBlockList() {
        if defaultBlockList == nil {
            createDefaultBlockList()
        }
    }
    
    /// Erstellt Standard-Blockliste und Standard-Blocklisten
    private func createDefaultBlockList() {
        // Erstelle Standard-Blockliste "Klassik"
        let defaultList = BlockList(
            name: "Klassik",
            appTokens: [],
            urls: [],
            isDefault: true
        )
        
        // Erstelle weitere Standard-Blocklisten
        let standardLists = StandardBlockLists.createStandardBlockLists()
        
        blockLists = [defaultList] + standardLists
        defaultBlockList = defaultList
        saveBlockLists()
    }
    
    /// Erstellt Standard-Blocklisten neu (wenn noch nicht vorhanden)
    func ensureStandardBlockLists() {
        let standardIds = ["standard-social-media", "standard-entertainment", "standard-gaming", "standard-all-distractions"]
        let existingIds = blockLists.map { $0.id }
        
        // Prüfe welche Standard-Blocklisten fehlen
        let missingIds = standardIds.filter { !existingIds.contains($0) }
        
        if !missingIds.isEmpty {
            let standardLists = StandardBlockLists.createStandardBlockLists()
            let missingLists = standardLists.filter { missingIds.contains($0.id) }
            
            blockLists.append(contentsOf: missingLists)
            saveBlockLists()
        }
    }
}

