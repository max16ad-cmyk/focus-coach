//
//  GeminiService.swift
//  FocusCoach
//
//  Gemini AI Integration for Task Analysis & Verification
//

import Foundation

struct TaskAnalysisResult: Codable {
    let tasks: [AnalyzedTask]
    let coachMessage: String
}

struct AnalyzedTask: Codable, Identifiable {
    let id: String
    let title: String
    let category: TaskCategory
    let duration: Int
    let requiresProof: Bool
    let proofType: String?
    let proofDescription: String
    let suggestedStartTime: String
    let suggestedEndTime: String
}

struct VerificationResult: Codable {
    let accepted: Bool
    let confidence: Double
    let reason: String
    let detectedElements: [String]
    let coachMessage: String
}

struct URLAnalysisResult: Codable {
    let url: String
    let isEducational: Bool
    let category: URLCategory
    let confidence: Double
    let reason: String
    let detectedContent: [String]
    let shouldBlock: Bool
    let coachMessage: String
}

enum URLCategory: String, Codable {
    case educational = "Bildung"
    case entertainment = "Unterhaltung"
    case mixed = "Gemischt"
    case unknown = "Unbekannt"
}

// Neues Schema-Modell für erzwungenes JSON-Schema
struct StructuredTaskExtraction: Codable {
    let task: String  // Kernaufgabe
    let date: String  // YYYY-MM-DD oder leerer String
    let time: String  // HH:MM oder leerer String
}

struct VoiceTasksResponse: Codable {
    let tasks: [VoiceTaskResult]
}

struct VoiceTaskResult: Codable, Equatable {
    let title: String
    let date: String?
    let startTime: String?
    let endTime: String?
    let notes: String?
    
    // Bereinigten Titel zurückgeben
    var cleanedTitle: String {
        var clean = title.trimmingCharacters(in: .whitespaces)
        
        // Entferne Füllwörter am Anfang
        let prefixes = ["ich muss ", "ich möchte ", "ich will ", "ich werde ",
                        "muss ", "möchte ", "will ", "werde ",
                        "das ", "die ", "der ", "ein ", "eine ", "einen "]
        
        for prefix in prefixes {
            if clean.lowercased().hasPrefix(prefix) {
                clean = String(clean.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Ersten Buchstaben groß
        if !clean.isEmpty {
            return clean.prefix(1).uppercased() + clean.dropFirst()
        }
        
        return clean
    }
}

class GeminiService {
    static let shared = GeminiService()
    
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent"
    
    private init() {
        // Get API key from Info.plist (via INFOPLIST_KEY) or environment
        print("═══════════════════════════════════════════════════════")
        print("🔑 GEMINI API KEY INITIALISIERUNG")
        print("═══════════════════════════════════════════════════════")
        
        var foundKey: String? = nil
        
        // Methode 1: Direkt aus Bundle.main.infoDictionary
        if let key = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String, !key.isEmpty {
            foundKey = key
            print("✅ Methode 1: Bundle.main.infoDictionary - GEFUNDEN")
        } else {
            print("❌ Methode 1: Bundle.main.infoDictionary - NICHT GEFUNDEN")
        }
        
        // Methode 2: ProcessInfo Environment
        if foundKey == nil, let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !key.isEmpty {
            foundKey = key
            print("✅ Methode 2: ProcessInfo Environment - GEFUNDEN")
        } else if foundKey == nil {
            print("❌ Methode 2: ProcessInfo Environment - NICHT GEFUNDEN")
        }
        
        // Methode 3: Hardcoded als Fallback (TEMPORÄR für Testing)
        if foundKey == nil {
            // TEMPORÄR: Direkt aus Build Settings lesen
            // In Xcode Build Settings: INFOPLIST_KEY_GEMINI_API_KEY wird zu GEMINI_API_KEY in Info.plist
            // Aber wenn das nicht funktioniert, verwenden wir den Key direkt
            let hardcodedKey = "AIzaSyDJSe62_aSnft0UmjeDrgILaEqqNqxS0X8"
            if !hardcodedKey.isEmpty {
                foundKey = hardcodedKey
                print("✅ Methode 3: Hardcoded Key (TEMPORÄR) - VERWENDET")
                print("⚠️ WARNUNG: Hardcoded Key wird verwendet - sollte aus Info.plist kommen!")
            }
        }
        
        if let key = foundKey {
            self.apiKey = key
            print("✅✅✅ API-KEY GEFUNDEN ✅✅✅")
            print("✅ Länge: \(key.count) Zeichen")
            print("✅ Erste 10 Zeichen: \(key.prefix(10))...")
            AppLogger.shared.info("✅ GEMINI_API_KEY gefunden (Länge: \(key.count))")
        } else {
            self.apiKey = ""
            print("❌❌❌ API-KEY NICHT GEFUNDEN ❌❌❌")
            print("❌ Fallback-Parser wird verwendet")
            AppLogger.shared.warning("⚠️ GEMINI_API_KEY not found. AI features will use fallback.")
            // Debug: Zeige alle verfügbaren Keys
            if let infoDict = Bundle.main.infoDictionary {
                let allKeys = infoDict.keys.joined(separator: ", ")
                print("📋 Verfügbare Info.plist Keys: \(allKeys)")
                AppLogger.shared.debug("📋 Verfügbare Info.plist Keys: \(allKeys)")
            }
        }
        print("═══════════════════════════════════════════════════════")
    }
    
    // MARK: - Task Analysis
    
    func analyzeTasks(_ userInput: String) async throws -> TaskAnalysisResult {
        guard !apiKey.isEmpty else {
            // Fallback: Simple parsing
            return createFallbackTasks(from: userInput)
        }
        
        let prompt = """
        Du bist ein strenger Produktivitäts-Coach. Analysiere die folgenden Aufgaben und erstelle einen strukturierten Tagesplan.

        EINGABE: "\(userInput)"

        Für jede erkannte Aufgabe, liefere:

        1. Aufgabenname (kurz, klar)
        2. Kategorie (Lernen, Haushalt, Erledigung, Arbeit, Sport, Kreativ)
        3. Geschätzte Dauer (in Minuten)
        4. Ob ein Nachweis erforderlich ist (true/false)
        5. Art des Nachweises wenn nötig (photo, document, screenshot)
        6. Beschreibung des Nachweises
        7. Vorgeschlagene Startzeit (HH:mm)
        8. Vorgeschlagene Endzeit (HH:mm)

        REGELN FÜR NACHWEISE:
        - Lernen/Studieren → Foto von Notizen erforderlich
        - Aufräumen/Putzen → Vorher/Nachher Foto erforderlich
        - Sport/Training → Kein Nachweis (Ehrensystem)
        - Einkaufen/Erledigungen → Kein Nachweis
        - Kreative Arbeit → Screenshot oder Foto des Ergebnisses

        Antworte NUR mit validem JSON:
        {
          "tasks": [
            {
              "id": "uuid",
              "title": "Aufgabenname",
              "category": "Kategorie",
              "duration": 60,
              "requiresProof": true,
              "proofType": "photo",
              "proofDescription": "Foto von deinen Mathe-Notizen",
              "suggestedStartTime": "09:00",
              "suggestedEndTime": "10:00"
            }
          ],
          "coachMessage": "Kurze Nachricht an den User über den Plan"
        }
        """
        
        do {
            let result = try await callGeminiAPI(prompt: prompt)
            return try parseTaskAnalysis(result)
        } catch {
            AppLogger.shared.error("❌ Task analysis failed: \(error.localizedDescription)")
            return createFallbackTasks(from: userInput)
        }
    }
    
    // MARK: - Proof Verification
    
    func verifyProof(
        taskTitle: String,
        taskCategory: String,
        proofDescription: String,
        imageData: Data
    ) async throws -> VerificationResult {
        guard !apiKey.isEmpty else {
            return VerificationResult(
                accepted: true,
                confidence: 0.5,
                reason: "AI offline - Auto-verifiziert",
                detectedElements: [],
                coachMessage: "Nachweis akzeptiert (AI offline)"
            )
        }
        
        let base64Image = imageData.base64EncodedString()
        let prompt = """
        Du bist ein strenger Produktivitäts-Coach. Prüfe, ob dieses Bild als Nachweis für die folgende Aufgabe ausreicht.

        AUFGABE: "\(taskTitle)"
        KATEGORIE: "\(taskCategory)"
        ERWARTETER NACHWEIS: "\(proofDescription)"

        PRÜFKRITERIEN:
        - Ist relevanter Inhalt erkennbar?
        - Passt das Bild zur Aufgabe?
        - Ist es ein echtes Foto (kein Screenshot von Google)?
        - Zeigt es tatsächliche Arbeit/Ergebnis?

        SEI STRENG aber FAIR. Kein Gaming des Systems erlauben.

        Antworte NUR mit validem JSON:
        {
          "accepted": true/false,
          "confidence": 0.0-1.0,
          "reason": "Begründung auf Deutsch",
          "detectedElements": ["Was du erkennst"],
          "coachMessage": "Direkte Nachricht an den User"
        }
        """
        
        do {
            let result = try await callGeminiAPIWithImage(prompt: prompt, imageData: base64Image)
            return try parseVerificationResult(result)
        } catch {
            AppLogger.shared.error("❌ Proof verification failed: \(error.localizedDescription)")
            return VerificationResult(
                accepted: false,
                confidence: 0,
                reason: "Fehler bei der Analyse",
                detectedElements: [],
                coachMessage: "Konnte den Nachweis nicht prüfen. Bitte versuche es erneut."
            )
        }
    }
    
    // MARK: - URL Analysis
    
    /// Analysiert eine URL und bewertet, ob der Inhalt bildungsrelevant oder nur Unterhaltung ist
    func analyzeURL(_ urlString: String, pageTitle: String? = nil, pageDescription: String? = nil) async throws -> URLAnalysisResult {
        guard !apiKey.isEmpty else {
            // Fallback: Simple heuristic
            return createFallbackURLAnalysis(url: urlString)
        }
        
        // Extract domain and path
        let url = URL(string: urlString) ?? URL(string: "https://example.com")!
        let domain = url.host ?? ""
        let path = url.path
        
        // Build context for analysis
        var context = ""
        if let title = pageTitle, !title.isEmpty {
            context += "Seitentitel: \(title)\n"
        }
        if let description = pageDescription, !description.isEmpty {
            context += "Beschreibung: \(description)\n"
        }
        
        let prompt = """
        Du bist ein Produktivitäts-Coach. Analysiere diese URL und bewerte, ob der Inhalt BILDUNGSRELEVANT oder nur UNTERHALTUNG ist.
        
        URL: \(urlString)
        Domain: \(domain)
        Pfad: \(path)
        \(context.isEmpty ? "" : "Kontext:\n\(context)")
        
        BEWERTUNGSKRITERIEN:
        
        BILDUNG (isEducational: true):
        - Tutorials, Kurse, Lernvideos
        - Dokumentationen, Erklärvideos
        - Wissenschaftliche Inhalte
        - Skill-basierte Inhalte (Programmierung, Design, etc.)
        - Vorlesungen, Webinare
        - Dokumentationen, Guides
        
        UNTERHALTUNG (isEducational: false):
        - Musikvideos, Comedy
        - Vlogs, Lifestyle-Content
        - Gaming-Content (außer Tutorials)
        - Memes, Unterhaltungsvideos
        - Reality-TV, Shows
        - Reine Zeitverschwendung
        
        GEMISCHT:
        - Inhalte die beide Aspekte haben
        - Dokumentationen die unterhaltsam sind aber auch bildend
        
        WICHTIG:
        - Sei STRENG aber FAIR
        - Ein "Lernvideo" über Gaming-Tricks ist BILDUNG
        - Ein "Tutorial" das nur Unterhaltung ist, ist UNTERHALTUNG
        - Dokumentationen sind meist BILDUNG (auch wenn unterhaltsam)
        
        Antworte NUR mit validem JSON:
        {
          "url": "\(urlString)",
          "isEducational": true/false,
          "category": "Bildung" | "Unterhaltung" | "Gemischt" | "Unbekannt",
          "confidence": 0.0-1.0,
          "reason": "Kurze Begründung auf Deutsch",
          "detectedContent": ["Was du erkennst"],
          "shouldBlock": true/false,
          "coachMessage": "Direkte Nachricht an den User"
        }
        """
        
        do {
            let result = try await callGeminiAPI(prompt: prompt)
            return try parseURLAnalysis(result, url: urlString)
        } catch {
            AppLogger.shared.error("❌ URL analysis failed: \(error.localizedDescription)")
            return createFallbackURLAnalysis(url: urlString)
        }
    }
    
    /// Analysiert eine YouTube-URL spezifisch
    func analyzeYouTubeURL(_ urlString: String, videoTitle: String? = nil, videoDescription: String? = nil) async throws -> URLAnalysisResult {
        // Extract video ID if possible
        var videoID: String?
        if let url = URL(string: urlString),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            videoID = queryItems.first(where: { $0.name == "v" })?.value
        }
        
        let prompt = """
        Du bist ein Produktivitäts-Coach. Analysiere dieses YouTube-Video und bewerte, ob es BILDUNGSRELEVANT oder nur UNTERHALTUNG ist.
        
        YouTube URL: \(urlString)
        \(videoID != nil ? "Video ID: \(videoID!)\n" : "")
        \(videoTitle != nil ? "Video-Titel: \(videoTitle!)\n" : "")
        \(videoDescription != nil ? "Video-Beschreibung: \(videoDescription!)\n" : "")
        
        BEWERTUNGSKRITERIEN:
        
        BILDUNG (isEducational: true):
        ✅ Tutorials, How-To-Videos
        ✅ Programmierung, Coding-Tutorials
        ✅ Wissenschaft, Dokumentationen
        ✅ Sprachkurse, Lernvideos
        ✅ Skill-basierte Inhalte
        ✅ Vorlesungen, Kurse
        ✅ Erklärvideos, Guides
        
        UNTERHALTUNG (isEducational: false):
        ❌ Musikvideos, Songs
        ❌ Comedy, Memes
        ❌ Vlogs, Lifestyle
        ❌ Gaming-Streams (außer Tutorials)
        ❌ Unterhaltungsshows
        ❌ Reine Zeitverschwendung
        
        WICHTIG:
        - Ein "Tutorial" über Gaming-Tricks ist BILDUNG
        - Ein "Let's Play" ohne Lernwert ist UNTERHALTUNG
        - Dokumentationen sind BILDUNG (auch wenn unterhaltsam)
        - Skill-basierte Inhalte sind IMMER BILDUNG
        
        Antworte NUR mit validem JSON:
        {
          "url": "\(urlString)",
          "isEducational": true/false,
          "category": "Bildung" | "Unterhaltung" | "Gemischt" | "Unbekannt",
          "confidence": 0.0-1.0,
          "reason": "Kurze Begründung auf Deutsch",
          "detectedContent": ["Was du erkennst"],
          "shouldBlock": true/false,
          "coachMessage": "Direkte Nachricht an den User"
        }
        """
        
        do {
            let result = try await callGeminiAPI(prompt: prompt)
            return try parseURLAnalysis(result, url: urlString)
        } catch {
            AppLogger.shared.error("❌ YouTube URL analysis failed: \(error.localizedDescription)")
            return createFallbackURLAnalysis(url: urlString)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Erstellt den System-Prompt für erzwungenes JSON-Schema
    private func buildSystemInstruction() -> String {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        let tomorrowString = dateFormatter.string(from: tomorrow)
        
        return """
        Du bist ein zuverlässiger Zeitplan-Assistent. Deine Aufgabe ist es, aus dem eingegebenen Satz die Kernaufgabe, das zugehörige Datum und die Uhrzeit zu extrahieren.
        
        WICHTIGE REGELN:
        - TITEL: Entferne Füllwörter wie "ich muss", "ich möchte", "würde gerne", "ein/eine/der/die/das"
        - ZAHLEN IM TITEL: "Formel 1", "Phase 2" sind TITEL, NICHT Uhrzeiten!
        - DATUM: Verwende ISO 8601 Format (YYYY-MM-DD). "morgen" = \(tomorrowString), "übermorgen" = +2 Tage
        - UHRZEIT: Format HH:MM. "abends" = 18:00, "nachmittags" = 14:00, "morgens" = 09:00
        - Wenn ein Wert fehlt, verwende einen leeren String ("")
        
        Verwende die aktuelle lokale Zeit als Bezugspunkt für relative Angaben wie 'morgen' oder 'nächste Woche'.
        Heute ist \(todayString).
        """
    }
    
    /// Erstellt das JSON-Schema für erzwungene Struktur
    private func buildResponseSchema() -> [String: Any] {
        return [
            "type": "object",
            "properties": [
                "task": [
                    "type": "string",
                    "description": "Die extrahierte Kernaufgabe oder der Termin (z.B. 'Formel 1 gucken')."
                ],
                "date": [
                    "type": "string",
                    "description": "Das extrahierte Datum im Format YYYY-MM-DD. Wenn kein Datum gefunden wird, ein leerer String (\"\")."
                ],
                "time": [
                    "type": "string",
                    "description": "Die extrahierte Uhrzeit im Format HH:MM. Wenn keine Uhrzeit gefunden wird, ein leerer String (\"\")."
                ]
            ],
            "required": ["task", "date", "time"]
        ]
    }
    
    /// Parst Task mit erzwungenem JSON-Schema (wie im HTML-Code)
    private func parseTaskWithStructuredSchema(_ text: String) async throws -> StructuredTaskExtraction {
        print("═══════════════════════════════════════════════════════")
        print("🔵🔵🔵 parseTaskWithStructuredSchema WIRD AUFGERUFEN 🔵🔵🔵")
        print("🔵 Eingabe-Text: '\(text)'")
        print("═══════════════════════════════════════════════════════")
        
        AppLogger.shared.info("🔵 NEUE FUNKTION: parseTaskWithStructuredSchema wird verwendet")
        AppLogger.shared.info("🔵 Eingabe-Text: '\(text)'")
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            print("❌ Invalid URL")
            throw NSError(domain: "GeminiService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let systemInstruction = buildSystemInstruction()
        let responseSchema = buildResponseSchema()
        
        print("🔵 System-Instruction: \(systemInstruction.prefix(150))...")
        print("🔵 Response-Schema: \(responseSchema)")
        
        AppLogger.shared.info("🔵 System-Instruction erstellt: \(systemInstruction.prefix(100))...")
        AppLogger.shared.info("🔵 Response-Schema erstellt: \(responseSchema)")
        
        // Request Body mit erzwungenem JSON-Schema
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": text]
                    ]
                ]
            ],
            "systemInstruction": [
                "parts": [
                    ["text": systemInstruction]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json", // Erzwingt JSON
                "responseSchema": responseSchema // Erzwingt Schema
            ]
        ]
        
        print("🔵 Request Body erstellt mit responseMimeType: application/json")
        AppLogger.shared.info("🔵 Request Body erstellt mit responseMimeType: application/json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🔵 Sende Request an Gemini API: \(url.absoluteString)")
        AppLogger.shared.info("🔵 Sende Request an Gemini API...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("🔵 Response Status: \(httpResponse.statusCode)")
            AppLogger.shared.info("🔵 Response Status: \(httpResponse.statusCode)")
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        // Parse Response
        if let candidates = json?["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let jsonText = parts.first?["text"] as? String {
            
            print("🔵 JSON-Response erhalten: \(jsonText)")
            AppLogger.shared.info("🔵 JSON-Response erhalten: \(jsonText.prefix(200))...")
            
            // Parse JSON direkt (kein Markdown mehr nötig, da erzwungenes Schema)
            guard let jsonData = jsonText.data(using: .utf8) else {
                print("❌ Failed to convert JSON string to data")
                throw NSError(domain: "GeminiService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to data"])
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(StructuredTaskExtraction.self, from: jsonData)
            
            print("✅✅✅ Strukturierte Extraktion erfolgreich:")
            print("   task='\(result.task)'")
            print("   date='\(result.date)'")
            print("   time='\(result.time)'")
            print("═══════════════════════════════════════════════════════")
            
            AppLogger.shared.info("🔵 ✅ Strukturierte Extraktion erfolgreich: task='\(result.task)', date='\(result.date)', time='\(result.time)'")
            
            return result
        }
        
        print("❌ Invalid response format")
        AppLogger.shared.error("🔵 ❌ Invalid response format")
        throw NSError(domain: "GeminiService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
    }
    
    private func callGeminiAPI(prompt: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw NSError(domain: "GeminiService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let candidates = json?["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let text = parts.first?["text"] as? String {
            return text
        }
        
        throw NSError(domain: "GeminiService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
    }
    
    private func callGeminiAPIWithImage(prompt: String, imageData: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw NSError(domain: "GeminiService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": imageData
                            ]
                        ]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let candidates = json?["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let text = parts.first?["text"] as? String {
            return text
        }
        
        throw NSError(domain: "GeminiService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
    }
    
    private func parseTaskAnalysis(_ jsonString: String) throws -> TaskAnalysisResult {
        guard let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "GeminiService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
        }
        
        let decoder = JSONDecoder()
        let tasksData = try JSONSerialization.data(withJSONObject: json["tasks"] ?? [])
        let tasks = try decoder.decode([AnalyzedTask].self, from: tasksData)
        
        let coachMessage = json["coachMessage"] as? String ?? "Plan erstellt"
        
        return TaskAnalysisResult(tasks: tasks, coachMessage: coachMessage)
    }
    
    private func parseVerificationResult(_ jsonString: String) throws -> VerificationResult {
        guard let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "GeminiService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(VerificationResult.self, from: JSONSerialization.data(withJSONObject: json))
    }
    
    private func parseURLAnalysis(_ jsonString: String, url: String) throws -> URLAnalysisResult {
        guard let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "GeminiService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse URL analysis JSON"])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(URLAnalysisResult.self, from: JSONSerialization.data(withJSONObject: json))
    }
    
    private func createFallbackURLAnalysis(url: String) -> URLAnalysisResult {
        // Simple heuristic based on domain
        let domain = URL(string: url)?.host?.lowercased() ?? ""
        var isEducational = false
        var category = URLCategory.unknown
        var shouldBlock = true
        
        // Educational domains
        let educationalDomains = ["coursera", "edx", "khanacademy", "udemy", "udacity", "skillshare", "lynda", "codecademy", "freecodecamp", "youtube.com/education", "youtube.com/channel/UC", "youtube.com/c/"]
        
        // Check if domain contains educational keywords
        if educationalDomains.contains(where: { domain.contains($0) }) {
            isEducational = true
            category = .educational
            shouldBlock = false
        } else if domain.contains("youtube.com") {
            // YouTube: Default to entertainment, but allow override
            isEducational = false
            category = .entertainment
            shouldBlock = true
        } else {
            // Unknown: Block by default
            isEducational = false
            category = .unknown
            shouldBlock = true
        }
        
        return URLAnalysisResult(
            url: url,
            isEducational: isEducational,
            category: category,
            confidence: 0.5,
            reason: "Automatische Analyse (KI offline)",
            detectedContent: [domain],
            shouldBlock: shouldBlock,
            coachMessage: "URL konnte nicht vollständig analysiert werden. Standardmäßig blockiert."
        )
    }
    
    /// Parst Spracheingabe und extrahiert Task-Informationen
    /// VERBESSERT: Unterstützt mehrere Tasks, KI mit Validierung
    func parseTaskFromVoice(_ text: String) async -> [VoiceTaskResult] {
        // FORCE PRINT - Sichtbar in Xcode Console
        print("═══════════════════════════════════════════════════════")
        print("🎯 parseTaskFromVoice WIRD AUFGERUFEN")
        print("🎯 Eingabe-Text: '\(text)'")
        print("🎯 API Key Status: \(apiKey.isEmpty ? "LEER ❌" : "Vorhanden ✅ (Länge: \(apiKey.count))")")
        print("═══════════════════════════════════════════════════════")
        
        // Debug: Zeige API Key Status
        AppLogger.shared.info("🔍 API Key Status: \(apiKey.isEmpty ? "LEER" : "Vorhanden (Länge: \(apiKey.count))")")
        
        // KI ZUERST verwenden (wenn API-Key vorhanden)
        if !apiKey.isEmpty {
            print("✅✅✅ NEUE FUNKTION MIT JSON-SCHEMA WIRD VERWENDET ✅✅✅")
            AppLogger.shared.info("🤖 ====== NEUE FUNKTION WIRD VERWENDET ======")
            AppLogger.shared.info("🤖 Verwende KI-Parser mit JSON-Schema für: '\(text)'")
            do {
                // 1. KI-Parsing mit erzwungenem JSON-Schema
                print("🔵 Rufe parseTaskWithStructuredSchema auf...")
                AppLogger.shared.info("🤖 Rufe parseTaskWithStructuredSchema auf...")
                let extraction = try await parseTaskWithStructuredSchema(text)
                
                print("🔵 Extraktion erhalten: task='\(extraction.task)', date='\(extraction.date)', time='\(extraction.time)'")
                AppLogger.shared.info("🤖 Extraktion erhalten: task='\(extraction.task)', date='\(extraction.date)', time='\(extraction.time)'")
                
                // 2. Konvertiere zu VoiceTaskResult
                let task = VoiceTaskResult(
                    title: extraction.task,
                    date: extraction.date.isEmpty ? nil : extraction.date,
                    startTime: extraction.time.isEmpty ? nil : extraction.time,
                    endTime: nil, // Endzeit wird später berechnet falls nötig
                    notes: nil
                )
                
                print("🔵 VoiceTaskResult: title='\(task.title)', date=\(task.date ?? "nil"), startTime=\(task.startTime ?? "nil")")
                AppLogger.shared.info("🤖 VoiceTaskResult erstellt: title='\(task.title)', date=\(task.date ?? "nil"), startTime=\(task.startTime ?? "nil")")
                
                // 3. Lokale Validierung/Korrektur
                let validatedTasks = TaskValidator.validate([task], context: text)
                
                print("✅✅✅ ERFOLG: '\(validatedTasks.first?.title ?? "nil")' | Datum: \(validatedTasks.first?.date ?? "nil") | Zeit: \(validatedTasks.first?.startTime ?? "nil")")
                AppLogger.shared.info("✅ KI-Parser erfolgreich: '\(validatedTasks.first?.title ?? "nil")' | Datum: \(validatedTasks.first?.date ?? "nil") | Zeit: \(validatedTasks.first?.startTime ?? "nil")")
                return validatedTasks
            } catch {
                print("❌❌❌ FEHLER: \(error.localizedDescription)")
                AppLogger.shared.error("❌ KI-Parsing fehlgeschlagen: \(error.localizedDescription)")
                AppLogger.shared.warning("⚠️ Verwende Fallback: \(error.localizedDescription)")
                // Fallback bei Fehler
            }
        } else {
            print("⚠️⚠️⚠️ KEIN API-KEY - VERWENDE FALLBACK ⚠️⚠️⚠️")
            AppLogger.shared.warning("⚠️ Kein API-Key vorhanden (leer), verwende Fallback-Parser")
        }
        
        // Fallback nur wenn KI fehlgeschlagen oder kein API-Key
        print("📝📝📝 FALLBACK-PARSER WIRD VERWENDET 📝📝📝")
        AppLogger.shared.info("📝 Verwende Fallback-Parser für: '\(text)'")
        let fallbackResult = parseTaskFromVoiceFallback(text)
        print("📝 Fallback-Result: '\(fallbackResult.title)' | Datum: \(fallbackResult.date ?? "nil") | Zeit: \(fallbackResult.startTime ?? "nil")")
        AppLogger.shared.info("✅ Fallback-Parser: '\(fallbackResult.title)' | Datum: \(fallbackResult.date ?? "nil") | Zeit: \(fallbackResult.startTime ?? "nil")")
        return [fallbackResult]
    }
    
    /// Erstellt den verbesserten Prompt für KI-Parsing
    private func buildImprovedPrompt(_ text: String) -> String {
        // Get current date for context
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        let tomorrowString = dateFormatter.string(from: tomorrow)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let currentTime = timeFormatter.string(from: today)
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "de_DE")
        weekdayFormatter.dateFormat = "EEEE"
        let weekdayToday = weekdayFormatter.string(from: today)
        
        // Berechne nächsten Montag
        var nextMonday = today
        let weekday = calendar.component(.weekday, from: today)
        let daysUntilMonday = (2 - weekday + 7) % 7
        if daysUntilMonday == 0 {
            nextMonday = calendar.date(byAdding: .day, value: 7, to: today) ?? today
        } else {
            nextMonday = calendar.date(byAdding: .day, value: daysUntilMonday, to: today) ?? today
        }
        let nextMondayString = dateFormatter.string(from: nextMonday)
        
        return """
        Du bist ein intelligenter Termin-Assistent. Analysiere die Spracheingabe und extrahiere ALLE Aufgaben.
        
        SPRACHEINGABE: "\(text)"
        
        KONTEXT:
        - Heute: \(todayString) (\(weekdayToday))
        - Morgen: \(tomorrowString)
        - Aktuelle Uhrzeit: \(currentTime)
        
        WICHTIGE REGELN:
        1. MEHRERE AUFGABEN: Ein Satz kann mehrere Aufgaben enthalten! "Formel 1 gucken, dann aufräumen" = 2 Aufgaben
        
        2. ZAHLEN IM TITEL: "Formel 1", "Phase 2", "Staffel 3" sind TITEL, NICHT Uhrzeiten!
        
        3. UHRZEITEN: Nur wenn "Uhr", "um", oder Zeitformat genannt wird: "um 15 Uhr", "15:00", "nachmittags"
        
        4. TITEL BEREINIGEN: Entferne "ich muss", "ich möchte", "würde gerne", "ein/eine/der/die/das"
        
        5. REIHENFOLGE: Wenn "danach", "dann", "anschließend" → nächste Aufgabe kommt nach der vorherigen
        
        ZEITWÖRTER:
        - "morgens/Vormittag" → 09:00
        - "mittags" → 12:00
        - "nachmittags" → 14:00
        - "abends" → 18:00
        - "nachts" → 22:00
        
        BEISPIELE:
        
        Eingabe: "Morgen um 15 Uhr Formel 1 gucken, danach mein Zimmer aufräumen"
        Ausgabe:
        {
          "tasks": [
            {"title": "Formel 1 gucken", "date": "\(tomorrowString)", "startTime": "15:00", "endTime": "17:00", "notes": null},
            {"title": "Zimmer aufräumen", "date": "\(tomorrowString)", "startTime": "17:00", "endTime": null, "notes": null}
          ]
        }
        
        Eingabe: "Ich muss die Küche aufräumen und dann Phase 2 vom Projekt fertig machen"
        Ausgabe:
        {
          "tasks": [
            {"title": "Küche aufräumen", "date": null, "startTime": null, "endTime": null, "notes": null},
            {"title": "Phase 2 vom Projekt fertig machen", "date": null, "startTime": null, "endTime": null, "notes": null}
          ]
        }
        
        Eingabe: "Am Montag abends mit Freunden treffen"
        Ausgabe:
        {
          "tasks": [
            {"title": "Mit Freunden treffen", "date": "\(nextMondayString)", "startTime": "18:00", "endTime": null, "notes": null}
          ]
        }
        
        ANTWORTE NUR MIT VALIDEM JSON (kein Markdown, kein ```):
        {"tasks": [...]}
        """
    }
    
    // MARK: - Fallback Parser (works without API, always returns a result)
    
    private func parseTaskFromVoiceFallback(_ text: String) -> VoiceTaskResult {
        let lowercased = text.lowercased()
        var title = text
        var date: String? = nil
        var startTime: String? = nil
        var endTime: String? = nil
        
        // Calculate tomorrow's date
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let tomorrowString = dateFormatter.string(from: tomorrow)
        
        // Parse date keywords
        if lowercased.contains("morgen") {
            date = tomorrowString
            title = title.replacingOccurrences(of: "morgen", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespaces)
        } else if lowercased.contains("übermorgen") {
            if let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today) {
                date = dateFormatter.string(from: dayAfterTomorrow)
            }
            title = title.replacingOccurrences(of: "übermorgen", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespaces)
        }
        
        // Parse time patterns - improved recognition (check each pattern individually)
        // Check for "nachmittag" FIRST (before other patterns) to catch it properly
        if lowercased.contains("nachmittag") || lowercased.contains("nach mittag") {
            startTime = "14:00"
            endTime = "17:00"
            // Remove from title
            title = title.replacingOccurrences(of: "nachmittag", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "nach mittag", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "am nachmittag", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespaces)
        }
        
        // Then check other patterns
        let timePatterns: [(pattern: String, start: String, end: String)] = [
            ("morgens|am morgen|früh|früh morgens", "08:00", "12:00"),
            ("vormittags|vormittag|vor mittag", "09:00", "12:00"),
            ("mittags|am mittag|zu mittag", "12:00", "14:00"),
            ("abends|am abend|abend", "18:00", "22:00"),
            ("spät abends|spät am abend", "20:00", "23:00")
        ]
        
        // Only check other patterns if nachmittag wasn't found
        if startTime == nil {
            for (pattern, start, end) in timePatterns {
                if lowercased.range(of: pattern, options: .regularExpression) != nil {
                    startTime = start
                    endTime = end
                    // Remove time keywords from title
                    title = title.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
                        .trimmingCharacters(in: .whitespaces)
                    break
                }
            }
        }
        
        // Special handling for "später" / "später noch" / "ich will später noch"
        if lowercased.contains("später") || lowercased.contains("später noch") || lowercased.contains("ich will später") {
            // Default to evening if no specific time mentioned
            if startTime == nil {
                startTime = "18:00"
                endTime = "22:00"
            }
            // Remove "später" phrases from title
            title = title.replacingOccurrences(of: "später noch", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "später", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "ich will", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespaces)
        }
        
        // Parse specific times like "17 uhr", "um 15", "15:00"
        let timeRegex = try? NSRegularExpression(pattern: "(?:um\\s+)?(\\d{1,2})(?:\\s*uhr)?(?:\\s*:?(\\d{2}))?", options: .caseInsensitive)
        if let regex = timeRegex {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if let match = results.first {
                let hourRange = match.range(at: 1)
                let minuteRange = match.range(at: 2)
                
                if hourRange.location != NSNotFound {
                    let hourString = nsString.substring(with: hourRange)
                    let minuteString = minuteRange.location != NSNotFound ? nsString.substring(with: minuteRange) : "00"
                    
                    if let hour = Int(hourString), hour >= 0 && hour <= 23 {
                        startTime = String(format: "%02d:%@", hour, minuteString)
                        // End time is 1 hour later
                        let endHour = (hour + 1) % 24
                        endTime = String(format: "%02d:00", endHour)
                        
                        // Remove time from title
                        let timePattern = "(?:um\\s+)?\(hourString)(?:\\s*uhr)?(?:\\s*:?\(minuteString))?"
                        title = title.replacingOccurrences(of: timePattern, with: "", options: .regularExpression)
                            .trimmingCharacters(in: .whitespaces)
                    }
                }
            }
        }
        
        // Clean up title
        title = title.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Ensure title is not empty - if empty, use original text
        if title.isEmpty {
            title = text.trimmingCharacters(in: .whitespaces)
        }
        
        // Final cleanup: remove common filler words (improved)
        let fillerWords = ["ich", "muss", "soll", "sollte", "will", "möchte", "habe", "hat", "noch", "mal", "dann", "auch"]
        for filler in fillerWords {
            let pattern = "\\b\(filler)\\b"
            title = title.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
                .trimmingCharacters(in: .whitespaces)
        }
        
        // Remove "was machen" / "etwas machen" patterns
        title = title.replacingOccurrences(of: "was machen", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "etwas machen", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        
        // If still empty, use original text
        if title.isEmpty {
            title = text.trimmingCharacters(in: .whitespaces)
        }
        
        return VoiceTaskResult(
            title: title.isEmpty ? "Neue Aufgabe" : title,
            date: date,
            startTime: startTime,
            endTime: endTime,
            notes: nil
        )
    }
    
    private func createMinimalVoiceTaskResult(from text: String) -> VoiceTaskResult {
        let cleaned = text.trimmingCharacters(in: .whitespaces)
        return VoiceTaskResult(
            title: cleaned.isEmpty ? "Neue Aufgabe" : cleaned,
            date: nil,
            startTime: nil,
            endTime: nil,
            notes: nil
        )
    }
    
    private func parseVoiceTasksResponse(_ jsonString: String) throws -> VoiceTasksResponse {
        // Clean JSON string (remove markdown code blocks if present)
        var cleanedJson = jsonString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedJson.data(using: .utf8) else {
            throw NSError(domain: "GeminiService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to data"])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(VoiceTasksResponse.self, from: data)
    }
    
    private func parseVoiceTaskResult(_ jsonString: String) throws -> VoiceTaskResult {
        // Clean JSON string (remove markdown code blocks if present)
        var cleanedJson = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks
        if cleanedJson.hasPrefix("```") {
            let lines = cleanedJson.components(separatedBy: .newlines)
            cleanedJson = lines.dropFirst().dropLast().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Remove "json" prefix if present
        if cleanedJson.hasPrefix("json") {
            cleanedJson = String(cleanedJson.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard let data = cleanedJson.data(using: .utf8) else {
            throw NSError(domain: "GeminiService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to data"])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(VoiceTaskResult.self, from: data)
    }
    
    // MARK: - Task Validator
    
    struct TaskValidator {
        /// Validiert und korrigiert die KI-Ergebnisse
        static func validate(_ tasks: [VoiceTaskResult], context: String) -> [VoiceTaskResult] {
            return tasks.map { task in
                var corrected = task
                
                // 1. Fix: "Formel 1" nicht als 01:00 interpretieren
                if corrected.title.lowercased().contains("formel 1") ||
                   corrected.title.lowercased().contains("phase 1") ||
                   corrected.title.lowercased().contains("teil 1") ||
                   corrected.title.lowercased().contains("staffel 1") {
                    if corrected.startTime == "01:00" {
                        corrected = VoiceTaskResult(
                            title: corrected.title,
                            date: corrected.date,
                            startTime: nil,  // Zeit entfernen
                            endTime: corrected.endTime,
                            notes: corrected.notes
                        )
                    }
                }
                
                // 2. Fix: Unrealistische Zeiten (z.B. 01:00-02:00 nachts)
                if let startTime = corrected.startTime,
                   let hour = Int(startTime.prefix(2)),
                   hour >= 0 && hour <= 5 {
                    // Wahrscheinlich falsch - prüfe ob im Original "nachts" steht
                    if !context.lowercased().contains("nacht") {
                        corrected = VoiceTaskResult(
                            title: corrected.title,
                            date: corrected.date,
                            startTime: nil,
                            endTime: nil,
                            notes: corrected.notes
                        )
                    }
                }
                
                // 3. Fix: Prüfe ob Zeit explizit im Originaltext genannt wurde
                if let startTime = corrected.startTime,
                   !timeWasExplicitlyMentioned(startTime, in: context) {
                    // Zeit wurde nicht explizit genannt - könnte falsch sein
                    // Aber wir behalten sie erstmal, da KI intelligent genug sein sollte
                }
                
                return corrected
            }
        }
        
        /// Prüft ob eine Zeit im Originaltext explizit genannt wurde
        static func timeWasExplicitlyMentioned(_ time: String?, in text: String) -> Bool {
            guard let time = time else { return false }
            
            let patterns = [
                "um \(time.prefix(2))",
                "\(time.prefix(2)) uhr",
                "\(time.prefix(2)):00",
                time
            ]
            
            let lowercased = text.lowercased()
            return patterns.contains { lowercased.contains($0.lowercased()) }
        }
    }
    
    private func createFallbackTasks(from input: String) -> TaskAnalysisResult {
        let tasks = input.split(separator: ",")
            .prefix(5)
            .enumerated()
            .map { index, task in
                AnalyzedTask(
                    id: "task-\(Date().timeIntervalSince1970)-\(index)",
                    title: String(task).trimmingCharacters(in: .whitespaces),
                    category: .erledigung,
                    duration: 60,
                    requiresProof: false,
                    proofType: nil,
                    proofDescription: "",
                    suggestedStartTime: String(format: "%02d:00", 9 + index),
                    suggestedEndTime: String(format: "%02d:00", 10 + index)
                )
            }
        
        return TaskAnalysisResult(
            tasks: tasks.isEmpty ? [
                AnalyzedTask(
                    id: "task-\(Date().timeIntervalSince1970)",
                    title: input.isEmpty ? "Neue Aufgabe" : input,
                    category: .erledigung,
                    duration: 60,
                    requiresProof: false,
                    proofType: nil,
                    proofDescription: "",
                    suggestedStartTime: "09:00",
                    suggestedEndTime: "10:00"
                )
            ] : tasks,
            coachMessage: "Aufgabe hinzugefügt. Du kannst Details später anpassen."
        )
    }
}

