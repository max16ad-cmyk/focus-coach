# 🆓 Gemini API - Kostenlose Nutzung Setup

## ✅ **Kostenloser Tier verfügbar!**

Die Gemini API von Google bietet einen **kostenlosen Tier** für Entwicklung und Prototyping:

- **60 Anfragen pro Minute** (mehr als genug für Spracherkennung!)
- **Kostenlos** für nicht-kommerzielle Nutzung
- **Keine Kreditkarte erforderlich** für den Free Tier

## 📝 **Setup-Anleitung**

### 1. **Google AI Studio öffnen**
- Gehe zu: https://aistudio.google.com/
- Melde dich mit deinem Google-Account an

### 2. **API Key erstellen**
- Klicke auf "Get API Key" oder "API Keys"
- Erstelle einen neuen API Key
- Kopiere den Key (wird nur einmal angezeigt!)

### 3. **API Key in die App einfügen**

#### Option A: Info.plist (Empfohlen)
1. Öffne `FocusCoach.xcodeproj`
2. Gehe zu `Info.plist` (oder Project Settings → Info)
3. Füge hinzu:
   - Key: `GEMINI_API_KEY`
   - Type: `String`
   - Value: `DEIN_API_KEY_HIER`

#### Option B: Environment Variable (für Development)
```bash
export GEMINI_API_KEY="dein-api-key-hier"
```

### 4. **App neu starten**
- Die App lädt den API Key automatisch beim Start
- Falls kein Key gefunden wird, verwendet die App den **Fallback-Parser** (funktioniert auch ohne API!)

## 🔍 **Wie die App den Key verwendet**

Die App sucht den Key in dieser Reihenfolge:
1. `Info.plist` → `GEMINI_API_KEY`
2. Environment Variable → `GEMINI_API_KEY`
3. Falls nicht gefunden → **Fallback-Parser** (funktioniert trotzdem!)

## ⚡ **Fallback-Parser**

Auch **ohne Gemini API** funktioniert die Spracherkennung:
- ✅ Erkennt "morgen", "übermorgen"
- ✅ Parst Uhrzeiten: "17 uhr", "um 15", "morgens", "nachmittags"
- ✅ Extrahiert Aufgaben-Titel
- ✅ Funktioniert komplett offline!

## 📊 **Nutzungslimits (Free Tier)**

- **60 Requests/Minute** → Mehr als genug für normale Nutzung
- **Keine täglichen Limits** (für Free Tier)
- **Rate Limiting**: Bei Überschreitung wird automatisch der Fallback verwendet

## 🚀 **Upgrade auf Paid Tier (optional)**

Falls du mehr brauchst:
- **Gemini Advanced**: ~21,99€/Monat
- Höhere Limits
- Bessere Modelle
- Kommerzielle Nutzung erlaubt

## ✅ **Testen**

1. App starten
2. Mikrofon-Button drücken
3. Sprechen: "morgen 17 uhr essen"
4. Prüfen: Werden Titel, Datum und Zeit erkannt?

Falls ja → API funktioniert! 🎉
Falls nein → Fallback-Parser wird verwendet (funktioniert auch!)

## 🔒 **Sicherheit**

- **NIEMALS** den API Key in Git committen!
- Füge `Info.plist` zu `.gitignore` hinzu (falls du den Key dort speicherst)
- Oder verwende Environment Variables nur lokal

## 💡 **Tipp**

Die App funktioniert **immer**, auch ohne API Key! Der Fallback-Parser ist sehr robust und erkennt die meisten gängigen Formulierungen.



