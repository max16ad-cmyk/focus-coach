# 🎤 Spracherkennung - Technische Erklärung

## Aktuelle Implementierung

### **Spracherkennung (Speech-to-Text):**
- **Technologie:** Apple's `SFSpeechRecognizer` (native iOS)
- **KI:** ❌ **NEIN** - Wir verwenden **keine KI** für die Spracherkennung
- **Funktionsweise:** 
  - Apple's Speech Framework wandelt Audio in Text um
  - Läuft lokal auf dem Gerät
  - Unterstützt Deutsch (`de-DE`)

### **Text-Parsing (Natural Language Understanding):**
- **Technologie:** Google Gemini AI
- **KI:** ✅ **JA** - Wir verwenden **Gemini AI** für das Parsing
- **Funktionsweise:**
  - Der erkannte Text wird an Gemini gesendet
  - Gemini extrahiert: Titel, Datum, Zeit, Notizen
  - Fallback-Parser wenn keine API verfügbar

## Warum keine KI für Spracherkennung?

**Apple's SFSpeechRecognizer ist bereits sehr gut:**
- ✅ Läuft lokal (keine Internet-Verbindung nötig)
- ✅ Schnell und zuverlässig
- ✅ Datenschutzfreundlich
- ✅ Kostenlos

**Gemini für Speech-to-Text würde bedeuten:**
- ❌ Audio müsste an Server gesendet werden (Datenschutz)
- ❌ Latenz durch Netzwerk
- ❌ Kosten für API-Calls
- ❌ Komplexere Implementierung

## Verbesserungen die wir gemacht haben:

1. **Kontinuierliche Erkennung:**
   - `isFinal` wird ignoriert (wurde zu früh true)
   - Erkennung läuft bis Benutzer explizit stoppt

2. **Silence Detection:**
   - Timer überwacht Stille
   - Verhindert zu frühes Stoppen

3. **Fehlerbehandlung:**
   - Nur bei kritischen Fehlern stoppen
   - Automatischer Neustart bei nicht-kritischen Fehlern

## Mögliche zukünftige Verbesserungen:

### Option 1: Gemini Speech-to-Text API
- **Vorteil:** Potentiell bessere Erkennung
- **Nachteil:** Datenschutz, Kosten, Latenz

### Option 2: Hybrid-Ansatz
- Apple für lokale Erkennung
- Gemini für Verbesserung bei Unsicherheiten

### Option 3: Besseres Parsing mit Gemini
- Mehr Kontext für Gemini
- Bessere Prompt-Engineering
- Mehr Trainingsdaten für Fallback-Parser

## Aktuelle Probleme & Lösungen:

### Problem: Erkennung stoppt zu früh
**Lösung:** `isFinal` wird ignoriert, nur manuelles Stoppen

### Problem: Transkription zu klein
**Lösung:** Schriftgröße erhöht auf 18pt

### Problem: Falsche Interpretation
**Lösung:** Verbessertes Gemini-Parsing mit besserem Prompt



