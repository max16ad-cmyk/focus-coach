//
//  BlockingService.swift
//  FocusCoach
//
//  Screen Time API Integration - App & Website Blocking
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings
import SafariServices
import UIKit

/// Service für App- und Website-Blockierung über Screen Time API
@MainActor
class BlockingService: ObservableObject {
    static let shared = BlockingService()
    
    // MARK: - Published Properties
    
    @Published var isAuthorized = false
    @Published var isBlockingActive = false
    @Published var blockedAppTokens: Set<ApplicationToken> = []
    @Published var isWebsiteBlockingEnabled = false
    @Published var blockedURLs: [String] = []
    @Published var intelligentBlockingEnabled = false
    @Published var urlAnalysisCache: [String: URLAnalysisResult] = [:]
    @Published var blockScreenStyle: CustomBlockScreen = CustomBlockScreen(style: .standard, customMessage: nil, backgroundImageName: nil)
    @Published var autoRotateBackgrounds = true // Automatisches Rotieren der Hintergrundbilder
    @Published var hasActiveTasks = false // Prüft ob aktive Tasks vorhanden sind
    @Published var familyActivitySelection = FamilyActivitySelection() {
        didSet {
            // Update blockedAppTokens when selection changes
            blockedAppTokens = familyActivitySelection.applicationTokens
            // Store the selection
            storeSelection(familyActivitySelection)
            
            print("📱 BlockingService: familyActivitySelection geändert - \(familyActivitySelection.applicationTokens.count) Apps")
        }
    }
    
    // MARK: - Private Properties
    
    private let authorizationCenter = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    private var currentTask: Task?
    private var backgroundRotationTask: _Concurrency.Task<Void, Never>?
    private var currentBackgroundIndex = 0
    
    // WICHTIG: Verwende ApplicationGroup für persistente Blockierung
    // Die Blockierung muss über die gleiche ApplicationGroup erfolgen
    private static let applicationGroupIdentifier = "group.com.MaxJacob.FocusCoach"
    
    // MARK: - Initialization
    
    private init() {
        checkAuthorizationStatus()
        // Load stored selection on init
        if let storedSelection = loadStoredSelection() {
            self.familyActivitySelection = storedSelection
            self.blockedAppTokens = storedSelection.applicationTokens
        }
        // Load block screen style - defer to avoid blocking
        DispatchQueue.main.async { [weak self] in
            self?.loadBlockScreenStyle()
            self?.loadAutoRotateSetting()
            if self?.autoRotateBackgrounds == true {
                self?.startBackgroundRotation()
            }
        }
    }
    
    // MARK: - Authorization
    
    /// Prüft den aktuellen Authorization-Status
    func checkAuthorizationStatus() {
        let status = authorizationCenter.authorizationStatus
        let wasAuthorized = isAuthorized
        
        switch status {
        case .approved:
            isAuthorized = true
        case .denied:
            isAuthorized = false
        case .notDetermined:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
        
        // Log status change
        if wasAuthorized != isAuthorized {
            print("✅ BlockingService: Authorization status changed: \(status) -> isAuthorized: \(isAuthorized)")
        }
    }
    
    /// Fordert Screen Time Authorization an
    func requestAuthorization() async throws {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            
            // Wait a moment for the system to update
            try await _Concurrency.Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Check status again
            await MainActor.run {
                checkAuthorizationStatus()
            }
            
            if !isAuthorized {
                throw BlockingError.authorizationDenied
            }
        } catch {
            // Log detailed error for debugging
            print("⚠️ BlockingService: Authorization error: \(error)")
            print("⚠️ Error details: \(error.localizedDescription)")
            
            // Check if it's a helper application error (common in Simulator)
            if error.localizedDescription.contains("helper application") {
                print("💡 Tipp: Screen Time API funktioniert möglicherweise nicht im Simulator.")
                print("💡 Teste auf einem echten iPhone oder prüfe die Entitlements-Konfiguration.")
            }
            
            throw BlockingError.authorizationFailed(error)
        }
    }
    
    // MARK: - App Blocking
    
    /// Blockiert die angegebenen Apps
    func blockApps(_ tokens: Set<ApplicationToken>) {
        guard isAuthorized else {
            print("⚠️ BlockingService: Cannot block apps - not authorized")
            return
        }
        
        guard !tokens.isEmpty else {
            print("⚠️ BlockingService: Keine Apps zum Blockieren übergeben")
            return
        }
        
        blockedAppTokens = tokens
        
        // WICHTIG: Setze Blockierung über ManagedSettings
        // Verwende .shield.applications für App-Blockierung
        store.shield.applications = tokens
        
        // ZUSÄTZLICH: Aktiviere auch Web Content Blocking wenn URLs vorhanden
        // (wird separat über blockSpecificWebsites gehandhabt)
        
        // WICHTIG: Synchronisiere die Einstellungen
        // Die Blockierung sollte sofort aktiv sein
        
        // Try to set custom message/name (if API available)
        setCustomBlockScreenMessage()
        
        isBlockingActive = true
        
        print("✅ BlockingService: Blocked \(tokens.count) apps with style: \(blockScreenStyle.style.rawValue)")
        
        // WICHTIG: Verifiziere sofort und nach Verzögerung
        let immediateCheck = store.shield.applications ?? Set<ApplicationToken>()
        if immediateCheck.count != tokens.count {
            print("⚠️ BlockingService: Sofortige Prüfung - Erwartet \(tokens.count), gefunden \(immediateCheck.count)")
        } else {
            print("✅ BlockingService: Sofortige Prüfung erfolgreich - \(immediateCheck.count) Apps blockiert")
        }
        
        // Verifiziere nach kurzer Verzögerung
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let shieldApps = self.store.shield.applications {
                if shieldApps.isEmpty && !tokens.isEmpty {
                    print("❌ BlockingService: KRITISCH - Blockierung wurde nicht aktiviert!")
                    print("   - Mögliche Ursachen:")
                    print("     1. Screen Time Authorization fehlt oder wurde widerrufen")
                    print("     2. ManagedSettings Store Problem")
                    print("     3. iOS Version zu alt (benötigt iOS 15+)")
                    print("   - Versuche erneut zu setzen...")
                    
                    // Versuche erneut zu setzen
                    self.store.shield.applications = tokens
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let retryApps = self.store.shield.applications, !retryApps.isEmpty {
                            print("✅ BlockingService: Nach Retry erfolgreich - \(retryApps.count) Apps blockiert")
                        } else {
                            print("❌ BlockingService: Retry fehlgeschlagen - Blockierung funktioniert nicht!")
                        }
                    }
                } else if shieldApps.count != tokens.count {
                    print("⚠️ BlockingService: Unvollständige Blockierung - Erwartet \(tokens.count), gefunden \(shieldApps.count)")
                } else {
                    print("✅ BlockingService: Blockierung erfolgreich aktiviert (\(shieldApps.count) Apps)")
                }
            } else {
                print("⚠️ BlockingService: store.shield.applications ist nil")
            }
        }
    }
    
    /// Setzt Custom Message für Blockierungsseite (wenn API verfügbar)
    private func setCustomBlockScreenMessage() {
        let message = blockScreenStyle.displayMessage
        
        // Try different approaches to set custom message
        // Note: The exact API might vary, we'll test what works
        
        // Approach 1: Try ShieldSettings (if available)
        // This might not be available in all iOS versions
        if #available(iOS 16.0, *) {
            // Try to set application name or custom message
            // Note: Exact API needs to be tested
        }
        
        // Approach 2: Store message for potential future use
        // Even if we can't set it directly, we can use it for other purposes
        UserDefaults.standard.set(message, forKey: "blockScreenMessage")
        UserDefaults.standard.set(blockScreenStyle.style.rawValue, forKey: "blockScreenStyle")
        
        print("📝 BlockingService: Set block screen message: \(message)")
    }
    
    /// Setzt Block Screen Style
    func setBlockScreenStyle(_ style: BlockScreenStyle, customMessage: String? = nil, backgroundImage: BlockScreenBackground? = nil) {
        let newStyle = CustomBlockScreen(
            style: style,
            customMessage: customMessage,
            backgroundImageName: backgroundImage?.rawValue
        )
        
        // Update published property (already on MainActor)
        self.blockScreenStyle = newStyle
        
        // Update blocking if active
        if isBlockingActive && !blockedAppTokens.isEmpty {
            blockApps(blockedAppTokens)
        }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(newStyle) {
            UserDefaults.standard.set(encoded, forKey: "customBlockScreen")
        }
    }
    
    /// Lädt gespeicherten Block Screen Style
    func loadBlockScreenStyle() {
        if let data = UserDefaults.standard.data(forKey: "customBlockScreen"),
           let decoded = try? JSONDecoder().decode(CustomBlockScreen.self, from: data) {
            // Already on MainActor
            self.blockScreenStyle = decoded
        }
    }
    
    /// Lädt Auto-Rotate Einstellung
    func loadAutoRotateSetting() {
        autoRotateBackgrounds = UserDefaults.standard.bool(forKey: "autoRotateBlockScreenBackgrounds")
        // Default to true if not set
        if !UserDefaults.standard.bool(forKey: "autoRotateBlockScreenBackgroundsSet") {
            autoRotateBackgrounds = true
            UserDefaults.standard.set(true, forKey: "autoRotateBlockScreenBackgrounds")
            UserDefaults.standard.set(true, forKey: "autoRotateBlockScreenBackgroundsSet")
        }
    }
    
    /// Startet automatisches Rotieren der Hintergrundbilder
    func startBackgroundRotation() {
        stopBackgroundRotation()
        
        // Rotiere alle 30 Sekunden mit Task
        backgroundRotationTask = _Concurrency.Task { @MainActor [weak self] in
            while !_Concurrency.Task.isCancelled {
                try? await _Concurrency.Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                if _Concurrency.Task.isCancelled { break }
                self?.rotateToNextBackground()
            }
        }
    }
    
    /// Stoppt automatisches Rotieren
    func stopBackgroundRotation() {
        backgroundRotationTask?.cancel()
        backgroundRotationTask = nil
    }
    
    /// Rotiert zum nächsten Hintergrundbild
    @MainActor
    private func rotateToNextBackground() {
        let backgrounds = BlockScreenBackground.allCases.filter { $0 != .none }
        guard !backgrounds.isEmpty else { return }
        
        currentBackgroundIndex = (currentBackgroundIndex + 1) % backgrounds.count
        let newBackground = backgrounds[currentBackgroundIndex]
        
        setBlockScreenStyle(
            blockScreenStyle.style,
            customMessage: blockScreenStyle.customMessage,
            backgroundImage: newBackground
        )
    }
    
    /// Setzt Auto-Rotate Einstellung
    func setAutoRotateBackgrounds(_ enabled: Bool) {
        autoRotateBackgrounds = enabled
        UserDefaults.standard.set(enabled, forKey: "autoRotateBlockScreenBackgrounds")
        
        if enabled {
            startBackgroundRotation()
        } else {
            stopBackgroundRotation()
        }
    }
    
    /// Entblockt alle Apps (nur wenn keine aktiven Tasks vorhanden sind)
    func unblockApps() {
        // Prüfe ob aktive Tasks vorhanden sind
        if hasActiveTasks {
            print("⚠️ BlockingService: Cannot unblock apps - active tasks are present")
            return
        }
        
        store.shield.applications = []
        blockedAppTokens.removeAll()
        isBlockingActive = false
        
        print("✅ BlockingService: Unblocked all apps")
    }
    
    /// Entblockt alle Apps (Emergency Unlock - ignoriert aktive Tasks)
    func emergencyUnblockApps() {
        store.shield.applications = []
        blockedAppTokens.removeAll()
        isBlockingActive = false
        
        print("🚨 BlockingService: Emergency unblock activated (ignoring active tasks)")
    }
    
    /// Entfernt eine spezifische App aus der Blockierungsliste (nur wenn keine aktiven Tasks vorhanden sind)
    func removeApp(_ token: ApplicationToken) {
        // Prüfe ob aktive Tasks vorhanden sind
        if hasActiveTasks {
            print("⚠️ BlockingService: Cannot remove app - active tasks are present")
            return
        }
        
        blockedAppTokens.remove(token)
        store.shield.applications = blockedAppTokens
        isBlockingActive = !blockedAppTokens.isEmpty
        
        print("✅ BlockingService: Removed app from blocking list")
    }
    
    // MARK: - Website Blocking
    
    /// Aktiviert Website-Blockierung
    func enableWebsiteBlocking() {
        guard isAuthorized else {
            print("⚠️ BlockingService: Cannot block websites - not authorized")
            return
        }
        
        // Note: Website blocking requires a different approach in ManagedSettings
        // For now, we'll use application blocking as the primary method
        // Website blocking can be added via Safari Content Blocker Extension if needed
        isWebsiteBlockingEnabled = true
        
        print("✅ BlockingService: Website blocking enabled (note: requires Safari Extension for full support)")
    }
    
    /// Deaktiviert Website-Blockierung (nur wenn keine aktiven Tasks vorhanden sind)
    func disableWebsiteBlocking() {
        // Prüfe ob aktive Tasks vorhanden sind
        if hasActiveTasks {
            print("⚠️ BlockingService: Cannot disable website blocking - active tasks are present")
            return
        }
        
        isWebsiteBlockingEnabled = false
        
        print("✅ BlockingService: Website blocking disabled")
    }
    
    /// Deaktiviert Website-Blockierung (Emergency Unlock - ignoriert aktive Tasks)
    func emergencyDisableWebsiteBlocking() {
        isWebsiteBlockingEnabled = false
        
        print("🚨 BlockingService: Emergency website blocking disabled (ignoring active tasks)")
    }
    
    /// Blockiert spezifische Websites
    func blockSpecificWebsites(_ domains: [String]) {
        guard isAuthorized else {
            print("⚠️ BlockingService: Cannot block websites - not authorized")
            return
        }
        
        blockedURLs = domains
        isWebsiteBlockingEnabled = true
        
        // Save to App Group UserDefaults for Content Blocker Extension
        if let sharedDefaults = UserDefaults(suiteName: "group.com.focuscoach.blocking") {
            sharedDefaults.set(domains, forKey: "blockedURLs")
            sharedDefaults.synchronize()
        }
        
        // Reload Content Blocker Extension
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.MaxJacob.FocusCoach.ContentBlocker") { error in
            if let error = error {
                print("⚠️ Error reloading content blocker: \(error)")
            } else {
                print("✅ Content Blocker Extension reloaded")
            }
        }
        
        print("✅ BlockingService: Website blocking enabled (domains: \(domains.joined(separator: ", ")))")
    }
    
    /// Fügt eine URL zur Blockierungsliste hinzu
    func addBlockedURL(_ url: String) {
        guard !blockedURLs.contains(url) else { return }
        blockedURLs.append(url)
        blockSpecificWebsites(blockedURLs)
    }
    
    /// Entfernt eine URL aus der Blockierungsliste (nur wenn keine aktiven Tasks vorhanden sind)
    func removeBlockedURL(_ url: String) {
        // Prüfe ob aktive Tasks vorhanden sind
        if hasActiveTasks {
            print("⚠️ BlockingService: Cannot remove URL - active tasks are present")
            return
        }
        
        blockedURLs.removeAll { $0 == url }
        urlAnalysisCache.removeValue(forKey: url)
        if blockedURLs.isEmpty {
            isWebsiteBlockingEnabled = false
        } else {
            blockSpecificWebsites(blockedURLs)
        }
    }
    
    /// Aktualisiert den Status ob aktive Tasks vorhanden sind
    func updateActiveTasksStatus(_ hasActive: Bool) {
        hasActiveTasks = hasActive
        print("📊 BlockingService: Active tasks status updated: \(hasActive)")
    }
    
    // MARK: - Intelligent URL Analysis
    
    /// Analysiert eine URL mit KI und entscheidet, ob sie blockiert werden soll
    func analyzeAndBlockURL(_ urlString: String, pageTitle: String? = nil, pageDescription: String? = nil) async -> Bool {
        // Check cache first
        if let cached = urlAnalysisCache[urlString] {
            return cached.shouldBlock
        }
        
        do {
            // Analyze URL
            let analysis: URLAnalysisResult
            
            // Use YouTube-specific analysis if it's YouTube
            if urlString.contains("youtube.com") || urlString.contains("youtu.be") {
                analysis = try await GeminiService.shared.analyzeYouTubeURL(urlString, videoTitle: pageTitle, videoDescription: pageDescription)
            } else {
                analysis = try await GeminiService.shared.analyzeURL(urlString, pageTitle: pageTitle, pageDescription: pageDescription)
            }
            
            // Cache result
            urlAnalysisCache[urlString] = analysis
            
            // If intelligent blocking is enabled, only block if shouldBlock is true
            if intelligentBlockingEnabled {
                return analysis.shouldBlock
            } else {
                // If intelligent blocking is disabled, use normal blocking logic
                return blockedURLs.contains(urlString)
            }
        } catch {
            AppLogger.shared.error("❌ URL analysis failed: \(error.localizedDescription)")
            // On error, block by default if in blocked list
            return blockedURLs.contains(urlString)
        }
    }
    
    /// Aktiviert intelligente Blockierung (KI-basiert)
    func enableIntelligentBlocking() {
        intelligentBlockingEnabled = true
        print("✅ BlockingService: Intelligent blocking enabled")
    }
    
    /// Deaktiviert intelligente Blockierung
    func disableIntelligentBlocking() {
        intelligentBlockingEnabled = false
        print("✅ BlockingService: Intelligent blocking disabled")
    }
    
    // MARK: - Task-based Blocking
    
    /// Startet Blockierung für einen spezifischen Task
    func startTaskBlocking(task: Task) {
        guard isAuthorized else {
            print("⚠️ BlockingService: Cannot start task blocking - not authorized")
            return
        }
        
        currentTask = task
        
        // Blockiere Apps (falls welche ausgewählt wurden)
        if !blockedAppTokens.isEmpty {
            store.shield.applications = blockedAppTokens
            isBlockingActive = true
        }
        
        // Website-Blockierung wird über Safari Extension realisiert
        // (siehe enableWebsiteBlocking für Details)
        
        print("✅ BlockingService: Started blocking for task: \(task.title)")
    }
    
    /// Stoppt Task-basierte Blockierung
    func stopTaskBlocking() {
        // Entblocke nur wenn kein Task mehr aktiv ist
        if currentTask == nil {
            store.shield.applications = []
            isBlockingActive = false
        }
        
        currentTask = nil
        
        print("✅ BlockingService: Stopped task blocking")
    }
    
    /// Entblockt alles (für Emergency Unlock)
    func emergencyUnblock() {
        store.shield.applications = []
        isBlockingActive = false
        
        print("🚨 BlockingService: Emergency unblock activated")
    }
    
    // MARK: - Reset
    
    /// Setzt alle Blockierungen zurück
    func resetAll() {
        store.shield.applications = []
        blockedAppTokens.removeAll()
        isBlockingActive = false
        isWebsiteBlockingEnabled = false
        currentTask = nil
        
        print("🔄 BlockingService: Reset all blocking")
    }
    
    // MARK: - Selection Storage
    
    /// Speichert die FamilyActivitySelection für spätere Verwendung
    func storeSelection(_ selection: FamilyActivitySelection) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(selection)
            UserDefaults.standard.set(data, forKey: "blockedAppsSelection")
            UserDefaults.standard.synchronize()
            print("✅ BlockingService: Stored FamilyActivitySelection")
        } catch {
            print("❌ BlockingService: Error storing selection: \(error)")
        }
    }
    
    /// Lädt die gespeicherte FamilyActivitySelection
    func loadStoredSelection() -> FamilyActivitySelection? {
        guard let data = UserDefaults.standard.data(forKey: "blockedAppsSelection") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let selection = try decoder.decode(FamilyActivitySelection.self, from: data)
            return selection
        } catch {
            print("⚠️ BlockingService: Error loading stored selection: \(error)")
            return nil
        }
    }
}

// MARK: - Errors

enum BlockingError: LocalizedError {
    case authorizationDenied
    case authorizationFailed(Error)
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Screen Time Authorization wurde verweigert. Bitte in den Einstellungen aktivieren."
        case .authorizationFailed(let error):
            return "Authorization fehlgeschlagen: \(error.localizedDescription)"
        case .notAuthorized:
            return "Screen Time Authorization ist nicht aktiviert."
        }
    }
}

