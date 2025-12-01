# 📦 WINDOWS APP - DISTRIBUTION & INSTALLATION

## 🎯 **WAS IST ES?**

Die Windows-App ist ein **richtiges Windows-Programm** (keine Browser-App!):
- ✅ **Native Desktop App** - Läuft wie jede andere Windows-App
- ✅ **Installation nötig** - `.exe` Installer zum Runterladen
- ✅ **System Integration** - System Tray, Desktop Shortcut, Startmenü
- ✅ **Offline fähig** - Funktioniert auch ohne Browser

---

## 📥 **FÜR ENDUSER: INSTALLATION**

### **Schritt 1: Installer herunterladen**
1. Gehe auf die Download-Seite
2. Lade `FocusCoach-Setup-1.0.0.exe` herunter
3. Datei ausführen

### **Schritt 2: Installation**
1. Windows fragt nach Admin-Rechten (für Blockierung nötig)
2. Installations-Pfad wählen (Standard: `C:\Program Files\FocusCoach`)
3. Desktop-Shortcut wird erstellt
4. App startet automatisch

### **Schritt 3: Nutzung**
- App öffnet sich als **eigenes Fenster** (nicht im Browser!)
- System Tray Icon erscheint
- Funktioniert wie jede andere Windows-App

---

## 🔧 **FÜR ENTWICKLER: BUILD & DISTRIBUTION**

### **1. Web-App bauen**
```bash
cd /Users/maxjacob/Documents/focus-coach
npm run build
```
→ Erstellt `dist/` Ordner mit gebauter Web-App

### **2. Windows-App bauen**
```bash
cd windows-desktop
npm install
npm run build
```
→ Erstellt `dist/` Ordner mit:
- `FocusCoach-Setup-1.0.0.exe` (Installer)
- `FocusCoach-1.0.0.exe` (Portable Version, optional)

### **3. Installer verteilen**
- Upload `FocusCoach-Setup-1.0.0.exe` auf:
  - Website (Download-Seite)
  - GitHub Releases
  - Windows Store (optional)

---

## 📊 **UNTERSCHIED: WEB-APP vs DESKTOP-APP**

### **Web-App (Browser)**
```
Browser öffnen
  ↓
URL eingeben: http://localhost:3000
  ↓
App läuft im Browser-Tab
  ↓
❌ Keine System-Integration
❌ Keine Blockierung möglich
❌ Muss Browser offen haben
```

### **Desktop-App (Windows Programm)**
```
Installer herunterladen
  ↓
Installation (wie jede andere App)
  ↓
Desktop-Shortcut klicken
  ↓
✅ Eigene App (kein Browser nötig)
✅ System-Integration (Tray, Notifications)
✅ Windows Firewall Blockierung möglich
✅ Läuft im Hintergrund
```

---

## 🎨 **WIE ES AUSSIEHT**

### **Desktop-App Fenster:**
```
┌─────────────────────────────────────┐
│  FocusCoach                    _ □ X │
├─────────────────────────────────────┤
│                                     │
│  [Deine Web-App UI hier]           │
│  - Tasks                            │
│  - Routinen                         │
│  - Blocklisten                      │
│                                     │
│  (Sieht aus wie Web-App,           │
│   läuft aber als Desktop-App)      │
│                                     │
└─────────────────────────────────────┘
```

### **System Tray:**
```
┌─────────────────┐
│  [FocusCoach]   │  ← Icon in Taskleiste
└─────────────────┘
```

---

## ✅ **VORTEILE DER DESKTOP-APP**

1. ✅ **Native Windows-App** - Kein Browser nötig
2. ✅ **System-Integration** - Tray, Notifications, Shortcuts
3. ✅ **Blockierung möglich** - Windows Firewall API
4. ✅ **Offline fähig** - Funktioniert ohne Internet (nach erstem Laden)
5. ✅ **Auto-Updates** - Automatische Updates möglich
6. ✅ **Professionell** - Sieht aus wie eine richtige App

---

## 📋 **ZUSAMMENFASSUNG**

**Die Windows-App ist:**
- ✅ Ein **richtiges Windows-Programm** (`.exe` Installer)
- ✅ Muss **heruntergeladen und installiert** werden
- ✅ Läuft **nicht im Browser** (eigene App)
- ✅ Nutzt deine **Web-App-Code** als Basis (Electron)

**Für User:**
- Download → Install → Nutzen (wie jede andere App)

**Für dich:**
- Build → Upload → Verteilen

---

## 🚀 **NÄCHSTE SCHRITTE**

1. ⏳ Icon erstellen (`icon.ico` und `icon.png`)
2. ⏳ Build testen
3. ⏳ Installer erstellen
4. ⏳ Download-Seite erstellen
5. ⏳ Code Signing (für Vertrauen)



