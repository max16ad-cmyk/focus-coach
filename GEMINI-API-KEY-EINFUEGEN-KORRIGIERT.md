# 🔑 Gemini API Key einfügen - KORRIGIERTE Anleitung

## ❌ Problem behoben:
Der Fehler "Multiple commands produce" entstand, weil das Projekt automatisch eine Info.plist generiert (`GENERATE_INFOPLIST_FILE = YES`).

## ✅ Lösung: API Key als Build Setting hinzufügen

### Schritt 1: In Xcode öffnen
1. Öffne das Projekt in Xcode
2. Klicke auf das **Projekt** (blauer Ordner oben links)
3. Wähle das **Target "FocusCoach"** aus
4. Gehe zum Tab **"Build Settings"**

### Schritt 2: Build Setting hinzufügen
1. Suche nach: **"Info.plist"** oder **"INFOPLIST"**
2. Oder gehe zu: **"Packaging"** → **"Info.plist Values"**
3. Klicke auf **"+"** um einen neuen Eintrag hinzuzufügen
4. **Key:** `INFOPLIST_KEY_GEMINI_API_KEY`
5. **Value:** Dein API Key (z.B. `AIzaSyDeinEchterApiKeyHier123456789`)

### Schritt 3: Für Debug UND Release
- Stelle sicher, dass der Key sowohl für **Debug** als auch **Release** gesetzt ist
- Oder setze ihn für **"Any iOS SDK"** (gilt für beide)

## 🔑 Wo bekomme ich den API Key?

1. Gehe zu: **https://aistudio.google.com/app/apikey**
2. Logge dich mit deinem Google-Account ein
3. Klicke auf **"Create API Key"**
4. Kopiere den Key (beginnt mit `AIzaSy...`)

## ✅ Nach dem Einfügen:

1. **Speichere** (Cmd+S)
2. **Clean Build Folder** (Shift+Cmd+K)
3. **Build** (Cmd+B)
4. **App neu starten**

## 🧪 Testen:

Nach dem Neustart sollte in den Logs stehen:
- `✅ KI-Parser erfolgreich` (statt Fallback-Parser)
- Die Spracherkennung sollte deutlich besser sein

## ⚠️ WICHTIG:

- **NIEMALS** den API Key in Git committen!
- Der Key sollte nur in den Build Settings sein
- Falls der Key geleakt wurde: Lösche ihn in Google AI Studio und erstelle einen neuen



