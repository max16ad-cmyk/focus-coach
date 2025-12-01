# 🔑 Gemini API Key einfügen - Schritt für Schritt

## 📍 Wo du den Key einfügen musst:

### Datei: `ios/FocusCoach/FocusCoach/Info.plist`

## 📝 Genau so einfügen:

1. **Öffne die Datei:** `ios/FocusCoach/FocusCoach/Info.plist`

2. **Füge diese Zeilen ein:**

```xml
<key>GEMINI_API_KEY</key>
<string>DEIN_API_KEY_HIER</string>
```

3. **Ersetze `DEIN_API_KEY_HIER` mit deinem echten API Key**

### Beispiel (so sollte es aussehen):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GEMINI_API_KEY</key>
	<string>AIzaSyDeinEchterApiKeyHier123456789</string>
</dict>
</plist>
```

## 🔑 Wo bekomme ich den API Key?

1. Gehe zu: **https://aistudio.google.com/app/apikey**
2. Logge dich mit deinem Google-Account ein
3. Klicke auf **"Create API Key"**
4. Kopiere den Key (beginnt mit `AIzaSy...`)

## ✅ Nach dem Einfügen:

1. **Speichere die Datei** (Cmd+S)
2. **Stoppe die App** komplett
3. **Starte die App neu**
4. Die KI sollte jetzt aktiv sein!

## ⚠️ WICHTIG:

- **NIEMALS** den API Key in Git committen!
- Der Key sollte nur in der Info.plist sein
- Falls der Key geleakt wurde: Lösche ihn in Google AI Studio und erstelle einen neuen

## 🧪 Testen:

Nach dem Neustart sollte in den Logs stehen:
- `✅ KI-Parser erfolgreich` (statt Fallback-Parser)
- Die Spracherkennung sollte deutlich besser sein



