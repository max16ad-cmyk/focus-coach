# 🔑 Gemini API Key - Anleitung

## Wo finde ich den API Key?

### Schritt 1: Google AI Studio öffnen
1. Gehe zu: **https://aistudio.google.com/app/apikey**
2. Logge dich mit deinem Google-Account ein (falls nötig)

### Schritt 2: API Key erstellen
1. Klicke auf **"Create API Key"** oder **"API Key erstellen"**
2. Wähle ein Google Cloud Projekt aus (oder erstelle ein neues)
3. Der API Key wird automatisch generiert
4. **WICHTIG:** Kopiere den Key sofort - er wird nur einmal angezeigt!

### Schritt 3: API Key in die iOS App einfügen

#### Option A: Info.plist (Empfohlen)
1. Öffne das Xcode-Projekt
2. Öffne `FocusCoach/Info.plist` (oder füge den Key im Project Settings hinzu)
3. Füge einen neuen Eintrag hinzu:
   - **Key:** `GEMINI_API_KEY`
   - **Type:** String
   - **Value:** Dein API Key (z.B. `AIzaSy...`)

#### Option B: Environment Variable (für Entwicklung)
1. In Xcode: Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Füge hinzu:
   - **Name:** `GEMINI_API_KEY`
   - **Value:** Dein API Key

### Schritt 4: App neu starten
Nach dem Hinzufügen des Keys:
1. Stoppe die App komplett
2. Starte sie neu
3. Die KI sollte jetzt aktiv sein!

## ✅ Überprüfung

Die App verwendet die KI automatisch, wenn der Key vorhanden ist. Du kannst es überprüfen:
- In den Logs sollte stehen: `✅ KI-Parser erfolgreich`
- Die Erkennung sollte deutlich besser sein

## 💰 Kosten

**Gemini 2.0 Flash ist KOSTENLOS:**
- 15 Requests pro Minute
- 1 Million Tokens pro Tag
- Keine Kreditkarte erforderlich
- Für normale Nutzung völlig ausreichend

## 🔒 Sicherheit

- **NIEMALS** den API Key in Git committen!
- Der Key sollte nur in `Info.plist` oder als Environment Variable sein
- Falls der Key geleakt wurde: Lösche ihn in Google AI Studio und erstelle einen neuen

## ❓ Probleme?

**"Kein API-Key vorhanden" in den Logs:**
- Überprüfe, ob der Key richtig in `Info.plist` eingetragen ist
- Stelle sicher, dass der Key-Name genau `GEMINI_API_KEY` ist
- Starte die App neu

**KI funktioniert nicht:**
- Überprüfe die Internetverbindung
- Stelle sicher, dass der API Key gültig ist
- Prüfe die Logs auf Fehlermeldungen



