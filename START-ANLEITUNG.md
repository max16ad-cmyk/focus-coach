# 🚀 FOCUS COACH - STARTANLEITUNG

## 📋 SCHNELLSTART

### 1. **Dependencies installieren** (falls noch nicht geschehen)

```bash
npm install
```

### 2. **Gemini API Key einrichten** (optional, für KI-Features)

Erstelle eine `.env` Datei im Projektordner:

```bash
# Windows PowerShell
echo "GEMINI_API_KEY=dein-api-key-hier" > .env

# Mac/Linux
echo "GEMINI_API_KEY=dein-api-key-hier" > .env
```

**Oder manuell:**
- Erstelle eine Datei namens `.env` im Projektordner
- Füge diese Zeile ein: `GEMINI_API_KEY=dein-api-key-hier`
- Ersetze `dein-api-key-hier` mit deinem echten Gemini API Key

**Wo bekomme ich einen API Key?**
- Gehe zu: https://aistudio.google.com/app/apikey
- Erstelle einen neuen API Key
- Kopiere ihn in die `.env` Datei

**Hinweis:** Die App funktioniert auch ohne API Key (mit Fallback-Modus), aber KI-Features sind dann eingeschränkt.

### 3. **App starten**

```bash
npm run dev
```

Die App öffnet sich automatisch im Browser unter:
**http://localhost:3000**

### 4. **Ersten Account erstellen**

1. Klicke auf "Register" oder "Sign Up"
2. Gib Email und Passwort ein
3. Klicke "Create Account"
4. Du wirst automatisch eingeloggt

### 5. **Ersten Tagesplan erstellen**

1. Du siehst den **Morning Lock** Screen
2. Gib deine Aufgaben ein (z.B. "Mathe lernen, Zimmer aufräumen")
3. Oder nutze die **🎤 Spracheingabe**
4. Klicke "Plan erstellen"
5. KI strukturiert deinen Plan
6. Bestätige den Plan

## 🎯 **WICHTIGE FEATURES TESTEN**

### ✅ **Spracheingabe testen:**
- Klicke auf "🎤 Spracheingabe"
- Sprich deine Aufgaben
- Text erscheint automatisch

### ✅ **Foto-Nachweis testen:**
- Erstelle eine Aufgabe mit Nachweis-Pflicht
- Markiere sie als erledigt
- Lade ein Foto hoch
- KI prüft den Nachweis

### ✅ **Multi-Device Sync testen:**
1. Öffne die App auf Gerät 1 (z.B. MacBook)
2. Erstelle einen Plan
3. Öffne die App auf Gerät 2 (z.B. iPhone)
4. Mit dem gleichen Account einloggen
5. Plan sollte automatisch erscheinen!

### ✅ **Einstellungen ändern:**
- Klicke auf das ⚙️ Icon oben rechts
- Ändere Coach-Persönlichkeit
- Änderungen werden auf allen Geräten synchronisiert

## 🔧 **TROUBLESHOOTING**

### Problem: "npm: command not found"
**Lösung:** Node.js installieren von https://nodejs.org

### Problem: "Port 3000 already in use"
**Lösung:** 
```bash
# Anderen Port verwenden
npm run dev -- --port 3001
```

### Problem: "Firebase Initialization Error"
**Lösung:** 
- Prüfe ob Internetverbindung besteht
- Firebase Config ist bereits in `services/firebase.ts` eingetragen

### Problem: "Gemini API Error"
**Lösung:**
- Prüfe ob `.env` Datei existiert
- Prüfe ob API Key korrekt ist
- App funktioniert auch ohne API Key (mit Fallback)

### Problem: "Spracheingabe funktioniert nicht"
**Lösung:**
- Nutze Chrome oder Edge (beste Unterstützung)
- Erlaube Mikrofon-Zugriff im Browser
- Prüfe Browser-Konsole auf Fehler

## 📱 **AUF IPHONE/IPAD NUTZEN**

1. Öffne Safari auf iPhone/iPad
2. Gehe zu: `http://deine-ip-adresse:3000`
   - Finde deine IP: `ipconfig` (Windows) oder `ifconfig` (Mac)
   - Beispiel: `http://192.168.1.100:3000`
3. Oder deploye auf Firebase Hosting (siehe DEPLOYMENT-GUIDE.md)

## 🎉 **FERTIG!**

Die App sollte jetzt laufen. Viel Erfolg mit deinem Focus Coach! 🚀

