# 🎤 SPRACHEINGABE - Architektur & Datenverarbeitung

## 📋 **Übersicht**

Die Spracheingabe funktioniert in **3 Phasen**:
1. **Sprache erfassen** → `VoiceInputService`
2. **Text transkribieren** → Apple Speech Recognition
3. **Daten parsen** → `GeminiService` (mit Fallback-Parser)

---

## 🏗️ **Komponenten**

### **1. VoiceInputService** (`VoiceInputService.swift`)
**Zuständigkeit:** Audio-Aufnahme & Transkription

```swift
class VoiceInputService: ObservableObject {
    @Published var recognizedText: String = ""  // Live-Transkription
    @Published var isListening: Bool = false     // Status
    
    func startListening()  // Startet Aufnahme
    func stopListening()   // Stoppt Aufnahme
}
```

**Wie es funktioniert:**
1. `AVAudioEngine` nimmt Audio auf
2. `SFSpeechRecognizer` transkribiert live
3. `recognizedText` wird kontinuierlich aktualisiert
4. `onChange(of: recognizedText)` in `VoiceInputView` reagiert darauf

**Datenfluss:**
```
Mikrofon → AVAudioEngine → SFSpeechRecognizer → recognizedText (String)
```

---

### **2. VoiceInputView** (`VoiceInputView.swift`)
**Zuständigkeit:** UI & Live-Anzeige

**State-Variablen:**
```swift
@State private var liveParsedData: VoiceTaskResult?  // Live geparste Daten
@State private var parsingTask: Task<Void, Never>?   // Parsing-Task
@State private var lastParsedText: String = ""       // Letzter geparster Text
```

**Live-Parsing Flow:**
```
recognizedText ändert sich
    ↓
onChange(of: recognizedText) wird getriggert
    ↓
startLiveParsing(text: newText) wird aufgerufen
    ↓
Debounce: Warte 1.5 Sekunden
    ↓
GeminiService.parseTaskFromVoice(text)
    ↓
liveParsedData wird gesetzt
    ↓
UI aktualisiert sich automatisch (SwiftUI @Published)
```

**UI-Komponenten:**
- **Transkription**: Zeigt `voiceService.recognizedText` live
- **Erkannte Daten**: Zeigt `liveParsedData` (wenn vorhanden)
- **Bearbeitungsmodus**: Editierbare Felder für `liveParsedData`

---

### **3. GeminiService** (`GeminiService.swift`)
**Zuständigkeit:** Text → Strukturierte Daten

**Hauptfunktion:**
```swift
func parseTaskFromVoice(_ text: String) async -> VoiceTaskResult?
```

**Parsing-Strategie (2-Stufen):**

#### **Stufe 1: Fallback-Parser** (immer, schnell)
```swift
parseTaskFromVoiceFallback(text) → VoiceTaskResult
```
- Funktioniert **ohne API**
- Erkennt: "morgen", "nachmittag", "17 uhr", etc.
- **Immer erfolgreich** (gibt immer ein Ergebnis zurück)

#### **Stufe 2: Gemini API** (optional, besser)
```swift
callGeminiAPI(prompt) → JSON → parseVoiceTaskResult()
```
- Funktioniert nur mit API Key
- Bessere Erkennung komplexer Formulierungen
- Fallback bei Fehler

**Datenstruktur:**
```swift
struct VoiceTaskResult {
    title: String      // "Essen", "Training", etc.
    date: String?      // "2024-11-30" oder nil
    startTime: String? // "14:00" oder nil
    endTime: String?   // "17:00" oder nil
    notes: String?      // Zusätzliche Notizen
}
```

---

## 🔄 **Vollständiger Datenfluss**

### **Beispiel: "morgen nachmittag essen"**

```
1. USER SPRICHT
   ↓
2. VoiceInputService.startListening()
   - AVAudioEngine startet
   - SFSpeechRecognizer beginnt Transkription
   ↓
3. recognizedText wird live aktualisiert
   "morgen" → "morgen nachmittag" → "morgen nachmittag essen"
   ↓
4. onChange(of: recognizedText) in VoiceInputView
   - Prüft: text.count > 5 && isListening
   - Ruft startLiveParsing("morgen nachmittag essen") auf
   ↓
5. startLiveParsing() - Debounce
   - Wartet 1.5 Sekunden
   - Prüft: Text hat sich nicht geändert?
   ↓
6. GeminiService.parseTaskFromVoice("morgen nachmittag essen")
   ↓
7. Fallback-Parser analysiert:
   - "morgen" → date = "2024-11-30"
   - "nachmittag" → startTime = "14:00", endTime = "17:00"
   - "essen" → title = "essen"
   ↓
8. VoiceTaskResult wird zurückgegeben:
   {
     title: "essen",
     date: "2024-11-30",
     startTime: "14:00",
     endTime: "17:00",
     notes: nil
   }
   ↓
9. liveParsedData wird gesetzt
   ↓
10. UI aktualisiert sich automatisch
    - "Erkannte Daten" Box erscheint
    - Zeigt: Titel, Datum, Zeit
   ↓
11. USER DRÜCKT "STOPPEN"
    ↓
12. processVoiceInput() oder direkt onTaskRecognized()
    ↓
13. NewTaskSheet öffnet sich mit vorausgefüllten Daten
```

---

## 🐛 **Problem-Analyse: "nachmittag" wird nicht erkannt**

### **Ursache:**
Der Regex-Pattern `"nachmittags|am nachmittag|nachmittag|nach mittag"` wird in einer Schleife geprüft, aber:
- Wenn ein anderer Pattern zuerst matched (z.B. "mittags"), wird `break` aufgerufen
- "nachmittag" wird dann nicht mehr geprüft

### **Lösung:**
1. **Spezielle Prüfung für "nachmittag" VOR der Schleife**
2. **Case-insensitive String.contains()** statt Regex (einfacher, robuster)

```swift
// VOR der Schleife:
if lowercased.contains("nachmittag") {
    startTime = "14:00"
    endTime = "17:00"
    // Remove from title
    title = title.replacingOccurrences(of: "nachmittag", ...)
}
```

---

## 📊 **Live-Parsing Details**

### **Debouncing:**
- **Warum?** Verhindert zu viele API-Calls während des Sprechens
- **Wie?** Wartet 1.5 Sekunden nach letzter Text-Änderung
- **Was passiert?** Nur wenn Text sich nicht ändert → Parse

### **Text-Änderungs-Prüfung:**
```swift
guard text != lastParsedText, 
      text.count >= max(3, lastParsedText.count + 3) else { return }
```
- Verhindert Parsing bei minimalen Änderungen
- Nur wenn mindestens 3 neue Zeichen → Parse

### **Task-Cancellation:**
```swift
parsingTask?.cancel()  // Vor neuem Parsing
```
- Verhindert Race Conditions
- Stoppt alte Parsing-Tasks wenn neuer Text kommt

---

## 🎯 **UI-Updates**

### **SwiftUI Reactive Updates:**
```swift
@State private var liveParsedData: VoiceTaskResult?
```

Wenn `liveParsedData` sich ändert:
1. SwiftUI erkennt Änderung automatisch
2. `if let liveData = liveParsedData` wird neu evaluiert
3. UI wird automatisch neu gerendert

### **Live-Anzeige:**
```swift
if let liveData = liveParsedData, !liveData.title.isEmpty {
    // Zeige "Erkannte Daten" Box
}
```

**Bedingung:** 
- `liveParsedData` muss gesetzt sein
- `title` muss nicht leer sein

---

## 🔧 **Fehlerbehandlung**

### **Fallback-Strategie:**
1. **Fallback-Parser** → Immer erfolgreich
2. **Gemini API** → Falls verfügbar, besser
3. **Bei Fehler** → Fallback-Parser wird verwendet

### **Error-States:**
- `liveParsedData = nil` → Keine Daten erkannt
- `isProcessing = true` → Parsing läuft
- `showError = true` → Fehler beim Speichern

---

## 💡 **Verbesserungen**

### **Aktuell implementiert:**
- ✅ Live-Transkription
- ✅ Live-Parsing (alle 1.5 Sek)
- ✅ Fallback-Parser (funktioniert ohne API)
- ✅ Bearbeitungsmodus für erkannte Daten

### **Noch zu verbessern:**
- ⚠️ "nachmittag" Erkennung (gerade gefixt)
- ⚠️ Live-Anzeige sollte IMMER sichtbar sein wenn Daten vorhanden
- ⚠️ Bessere Fehlerbehandlung bei Parsing-Fehlern

---

## 🧪 **Debugging**

### **Logging:**
```swift
print("🔄 Live-Parsing: '\(text)'")
print("✅ Live-Parsing erfolgreich: '\(result.title)' | Datum: \(result.date ?? "nil")")
print("⚠️ Live-Parsing fehlgeschlagen für: '\(text)'")
```

### **Prüf-Punkte:**
1. Wird `recognizedText` aktualisiert? → Console prüfen
2. Wird `startLiveParsing()` aufgerufen? → Breakpoint setzen
3. Wird `liveParsedData` gesetzt? → `onChange(of: liveParsedData)` prüfen
4. Wird UI aktualisiert? → `if let liveData` Bedingung prüfen



