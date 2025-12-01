# 🔨 WINDOWS APP BUILD - ANLEITUNG

## 📋 **VORAUSSETZUNGEN**

- ✅ Node.js 18+ installiert
- ✅ Windows 10/11 (für Build)
- ✅ Oder macOS/Linux mit Wine (für Cross-Platform Build)

---

## 🚀 **SCHRITT-FÜR-SCHRITT BUILD**

### **1. Web-App bauen**

```bash
# Im Hauptverzeichnis
cd /Users/maxjacob/Documents/focus-coach
npm run build
```

**Ergebnis:** `dist/` Ordner mit gebauter Web-App

### **2. Windows-App Dependencies installieren**

```bash
cd windows-desktop
npm install
```

**Installiert:**
- Electron
- electron-builder
- electron-updater
- concurrently, wait-on

### **3. Windows-App bauen**

```bash
npm run build
```

**Oder für Distribution:**

```bash
npm run dist
```

**Ergebnis:** `windows-desktop/dist/` mit:
- `FocusCoach-Setup-1.0.0.exe` ← **Das ist der Installer!**
- `latest.yml` (für Auto-Updater)

---

## 📦 **WAS WIRD GEBUILT?**

### **Installer (`FocusCoach-Setup-1.0.0.exe`)**
- **Größe:** ~100-150 MB (inkl. Electron Runtime)
- **Typ:** NSIS Installer
- **Features:**
  - Installation in `C:\Program Files\FocusCoach`
  - Desktop Shortcut
  - Startmenü Eintrag
  - Auto-Updater Integration

### **Inhalt des Installers:**
```
FocusCoach/
├── FocusCoach.exe          # Haupt-App
├── resources/
│   ├── app.asar            # Deine Web-App (gepackt)
│   └── electron.asar       # Electron Runtime
└── ...
```

---

## 🎯 **ENTWICKLUNG vs PRODUCTION**

### **Development (Lokale Entwicklung)**
```bash
npm run dev
```
- Lädt Web-App von `http://localhost:3000`
- Hot Reload aktiv
- DevTools geöffnet

### **Production (Gebaut)**
```bash
npm run build
```
- Nutzt gebaute Web-App aus `../dist/`
- Optimiert & gepackt
- Kein DevTools

---

## 📥 **DISTRIBUTION**

### **Option 1: Direct Download**
1. Upload `FocusCoach-Setup-1.0.0.exe` auf Server
2. Download-Link auf Website
3. User lädt herunter und installiert

### **Option 2: GitHub Releases**
1. GitHub Release erstellen
2. `FocusCoach-Setup-1.0.0.exe` hochladen
3. Auto-Updater nutzt `latest.yml`

### **Option 3: Windows Store**
1. Microsoft Store Developer Account
2. App einreichen
3. Automatische Updates über Store

---

## 🔐 **CODE SIGNING (Optional, aber empfohlen)**

Für Vertrauen beim Download:

```bash
# Code Signing Certificate benötigt
# Dann in package.json:
"win": {
  "certificateFile": "path/to/certificate.pfx",
  "certificatePassword": "password"
}
```

**Ohne Signing:**
- Windows zeigt Warnung beim Installieren
- User muss "Weitere Informationen" → "Trotzdem ausführen" klicken

**Mit Signing:**
- Keine Warnung
- Vertrauenswürdige App

---

## ✅ **ZUSAMMENFASSUNG**

**Die Windows-App ist ein richtiges Programm:**
- ✅ `.exe` Installer zum Runterladen
- ✅ Installation wie jede andere App
- ✅ Läuft als Desktop-App (nicht Browser)
- ✅ System-Integration (Tray, Shortcuts)

**Build-Prozess:**
1. Web-App bauen (`npm run build`)
2. Windows-App bauen (`cd windows-desktop && npm run build`)
3. Installer hochladen
4. User lädt herunter und installiert



