//
//  VoiceInputViewModel.swift
//  FocusCoach
//
//  KI-basierte Live-Analyse während des Sprechens
//

import Foundation
import Combine

@MainActor
class VoiceInputViewModel: ObservableObject {
    // MARK: - Published Properties (Live-Vorschau)
    @Published var tasks: [VoiceTaskResult] = [] // Unterstützt jetzt mehrere Tasks
    @Published var isAnalyzing = false
    @Published var error: String? = nil
    
    // MARK: - Computed Properties für Kompatibilität (zeigt ersten Task)
    var title: String {
        tasks.first?.cleanedTitle ?? ""
    }
    var date: String? {
        tasks.first?.date
    }
    var startTime: String? {
        tasks.first?.startTime
    }
    var endTime: String? {
        tasks.first?.endTime
    }
    var notes: String? {
        tasks.first?.notes
    }
    
    // MARK: - Private Properties
    private var analysisTask: _Concurrency.Task<Void, Never>?
    private var lastAnalyzedText: String = ""
    private let geminiService = GeminiService.shared
    
    // MARK: - Configuration
    private let debounceInterval: UInt64 = 500_000_000 // 0.5 Sekunden (schnell für Live-Updates)
    private let minTextLength = 5 // Mindestens 5 Zeichen bevor Analyse startet
    
    // MARK: - Public Methods
    
    /// Startet Live-Analyse während des Sprechens
    func analyzeLive(text: String, isListening: Bool) {
        // Cancel previous analysis
        analysisTask?.cancel()
        
        // Nur analysieren wenn:
        // 1. Text lang genug ist
        // 2. Text sich geändert hat
        // 3. Noch zuhört
        guard text.count >= minTextLength,
              text != lastAnalyzedText,
              isListening else {
            return
        }
        
        isAnalyzing = true
        error = nil
        
        // Debounce: Warte kurz bevor Analyse startet
        analysisTask = _Concurrency.Task {
            do {
                try await _Concurrency.Task.sleep(nanoseconds: debounceInterval)
                
                // Prüfe ob noch gültig
                guard isListening, text == self.lastAnalyzedText || text.count > self.lastAnalyzedText.count else {
                    return
                }
                
                // KI-Analyse (gibt jetzt Array zurück)
                print("🎯🎯🎯 VoiceInputViewModel ruft parseTaskFromVoice auf mit Text: '\(text)'")
                let results = await geminiService.parseTaskFromVoice(text)
                print("🎯🎯🎯 parseTaskFromVoice zurückgegeben: \(results.count) Ergebnis(se)")
                if let first = results.first {
                    print("🎯 Erstes Ergebnis: title='\(first.title)', date=\(first.date ?? "nil"), startTime=\(first.startTime ?? "nil")")
                }
                
                // Update Live-Vorschau
                await MainActor.run {
                    self.tasks = results
                    self.lastAnalyzedText = text
                    self.isAnalyzing = false
                    
                    AppLogger.shared.info("✅ Live-Analyse: \(results.count) Task(s) erkannt")
                    if let first = results.first {
                        AppLogger.shared.info("   → Titel='\(first.cleanedTitle)', Datum=\(first.date ?? "nil"), Zeit=\(first.startTime ?? "nil")")
                    }
                }
            } catch is CancellationError {
                // Task wurde abgebrochen, ignorieren
                return
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isAnalyzing = false
                    AppLogger.shared.error("❌ Live-Analyse fehlgeschlagen: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Stoppt Live-Analyse
    func stopAnalysis() {
        analysisTask?.cancel()
        analysisTask = nil
        isAnalyzing = false
    }
    
    /// Finale Analyse nach dem Stoppen
    func analyzeFinal(text: String) async -> [VoiceTaskResult] {
        guard !text.isEmpty else { return [] }
        
        isAnalyzing = true
        error = nil
        
        let results = await geminiService.parseTaskFromVoice(text)
        
        await MainActor.run {
            self.tasks = results
            self.isAnalyzing = false
        }
        
        return results
    }
    
    /// Reset alle Felder
    func reset() {
        tasks = []
        lastAnalyzedText = ""
        error = nil
        stopAnalysis()
    }
}
