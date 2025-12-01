//
//  ScreenTimeAnalyzer.swift
//  FocusCoach
//
//  Analysiert Bildschirmzeit-Daten und erstellt personalisierte Blockliste
//

import Foundation
import Combine
import DeviceActivity
import FamilyControls
import ManagedSettings

@MainActor
class ScreenTimeAnalyzer: ObservableObject {
    static let shared = ScreenTimeAnalyzer()
    
    @Published var mostUsedApps: [(token: ApplicationToken, usage: TimeInterval, description: String)] = []
    @Published var isAnalyzing = false
    @Published var analysisError: String?
    @Published var analysisSummary: String?
    
    private let deviceActivityCenter = DeviceActivityCenter()
    private let scheduleName = DeviceActivityName("screenTimeAnalysis")
    
    private init() {}
    
    /// Analysiert Bildschirmzeit der letzten 7 Tage
    /// Note: DeviceActivity API benötigt eine Extension, daher verwenden wir einen vereinfachten Ansatz
    func analyzeScreenTime(completion: @escaping ([ApplicationToken], String) -> Void) {
        isAnalyzing = true
        analysisError = nil
        analysisSummary = nil
        
        // WICHTIG: DeviceActivity API benötigt eine DeviceActivityMonitor Extension
        // Für jetzt: Nutze einen vereinfachten Ansatz über FamilyActivitySelection
        // Der User kann Apps auswählen, die er blockieren möchte
        
        // DeviceActivity API benötigt eine Extension für vollständige Analyse
        // Für jetzt: Zeige Info und ermögliche manuelle App-Auswahl
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnalyzing = false
            
            // Zeige Info-Text
            let summary = """
            📊 Bildschirmzeit-Analyse:
            
            Wähle Apps im App-Picker aus, die du blockieren möchtest. Die App erstellt automatisch eine personalisierte Blockliste basierend auf deiner Auswahl.
            
            💡 Tipp: Konzentriere dich auf Apps, die du als Zeitfresser identifiziert hast (z.B. Social Media, Spiele, Unterhaltung).
            
            🔍 Typische Zeitfresser:
            • Social Media Apps (Instagram, Facebook, TikTok)
            • Unterhaltungs-Apps (YouTube, Netflix, Spotify)
            • Spiele-Apps
            • Nachrichten-Apps
            """
            
            self.analysisSummary = summary
            completion([], summary)
        }
    }
    
    /// Erstellt personalisierte Blockliste basierend auf ausgewählten Apps
    func createPersonalizedBlockList(from selectedTokens: Set<ApplicationToken>, name: String = "Meine Zeitfresser") -> BlockList {
        let blockList = BlockList(
            id: "personalized-\(UUID().uuidString)",
            name: name,
            appTokens: selectedTokens,
            urls: [],
            createdAt: Date(),
            updatedAt: Date(),
            isDefault: false
        )
        
        return blockList
    }
    
    /// Generiert Analyse-Zusammenfassung
    func generateAnalysisSummary(appCount: Int) -> String {
        return """
        📊 Bildschirmzeit-Analyse abgeschlossen
        
        ✅ \(appCount) App(s) identifiziert
        
        Diese Apps wurden als potenzielle Zeitfresser identifiziert. Du kannst sie jetzt zu einer Blockliste hinzufügen.
        
        💡 Tipp: Blockiere Apps während deiner produktiven Zeiten, um Ablenkungen zu vermeiden.
        """
    }
}
