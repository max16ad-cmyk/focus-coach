# 🪟 WINDOWS DESKTOP APP - IMPLEMENTIERUNGSPLAN

## 🎯 **ÜBERSICHT**

Native Windows Desktop App für FocusCoach mit vollständiger Blockierungs-Funktionalität.

---

## 🛠️ **TECHNOLOGIE-STACK**

### **Option A: Electron (Empfohlen für schnelle Entwicklung)**
- ✅ **Vorteile:**
  - Schnelle Entwicklung (Web-Technologien)
  - Gleicher Code wie PWA
  - Cross-Platform (Windows, Mac, Linux)
  - Firebase Integration bereits vorhanden
  
- ⚠️ **Nachteile:**
  - Größere App-Größe (~100-200 MB)
  - Höherer RAM-Verbrauch
  - Keine native Windows-Integration

**Tech Stack:**
- Electron Framework
- React/TypeScript (wie PWA)
- Firebase SDK (bereits vorhanden)
- Windows Native APIs für Blockierung

### **Option B: .NET WPF/WinUI 3 (Native Windows)**
- ✅ **Vorteile:**
  - Native Windows-App
  - Bessere Performance
  - Vollständige Windows-Integration
  - Kleinere App-Größe
  
- ⚠️ **Nachteile:**
  - Neuer Code nötig (nicht Web-basiert)
  - Längere Entwicklungszeit
  - Nur Windows

**Tech Stack:**
- .NET 8 / C#
- WPF oder WinUI 3
- Firebase .NET SDK
- Windows Parental Controls API

### **Option C: Flutter Desktop**
- ✅ **Vorteile:**
  - Cross-Platform (Windows, Mac, Linux)
  - Ein Codebase für alle Plattformen
  - Native Performance
  
- ⚠️ **Nachteile:**
  - Neuer Code nötig
  - Windows-Integration komplexer

---

## 🎯 **EMPFOHLENE LÖSUNG: Electron**

**Warum Electron?**
1. ✅ Schnellste Entwicklung (PWA-Code wiederverwendbar)
2. ✅ Firebase bereits integriert
3. ✅ Gleiche UI/UX wie Web-Version
4. ✅ Einfache Updates über Auto-Updater

---

## 📦 **APP-STRUKTUR (Electron)**

```
focus-coach-desktop/
├── main/                    # Electron Main Process
│   ├── main.js             # App Entry Point
│   ├── window-manager.js   # Window Management
│   ├── auto-updater.js     # Auto-Update Logic
│   └── blocking-service.js # Windows Blocking Service
│
├── renderer/                # Electron Renderer Process (React App)
│   ├── src/                # PWA Code (wiederverwendbar)
│   ├── components/
│   ├── services/
│   └── ...
│
├── native/                  # Native Windows Modules
│   ├── blocking/           # Windows Blocking Implementation
│   │   ├── firewall.cpp   # Windows Firewall Integration
│   │   └── parental-controls.cpp # Windows Parental Controls
│   └── system-tray/        # System Tray Integration
│
└── build/                   # Build Configuration
    ├── electron-builder.yml
    └── installer.nsh       # NSIS Installer Script
```

---

## 🔒 **WINDOWS BLOCKIERUNG - IMPLEMENTIERUNG**

### **Methode 1: Windows Firewall (Empfohlen)**

```javascript
// native/blocking/firewall.js
const { exec } = require('child_process');

class WindowsFirewallBlocker {
    async blockApp(appPath) {
        // Blockiere App über Windows Firewall
        const command = `netsh advfirewall firewall add rule name="FocusCoach-Block-${appName}" dir=out action=block program="${appPath}" enable=yes`;
        exec(command, (error) => {
            if (error) console.error('Firewall block failed:', error);
        });
    }
    
    async blockURL(domain) {
        // Blockiere Domain über Hosts-Datei
        const hostsPath = 'C:\\Windows\\System32\\drivers\\etc\\hosts';
        const entry = `127.0.0.1 ${domain}\n`;
        // Append to hosts file
    }
}
```

**Vorteile:**
- ✅ System-Level Blockierung
- ✅ Funktioniert für alle Apps
- ✅ Keine zusätzlichen Permissions nötig

**Nachteile:**
- ⚠️ Benötigt Admin-Rechte
- ⚠️ User kann Firewall-Regeln manuell löschen

### **Methode 2: Windows Parental Controls**

```javascript
// native/blocking/parental-controls.js
const { exec } = require('child_process');

class WindowsParentalControls {
    async blockApp(bundleId) {
        // Nutze Windows Family Safety API
        // Benötigt Microsoft Account
    }
}
```

**Vorteile:**
- ✅ Offizielle Windows API
- ✅ Schwerer zu umgehen

**Nachteile:**
- ⚠️ Benötigt Microsoft Account
- ⚠️ Komplexe API

### **Methode 3: Browser Extension (Für Web-Apps)**

```javascript
// Browser Extension für Chrome/Edge
// Content Scripts blockieren URLs
// Funktioniert nur im Browser
```

---

## 📋 **FEATURES DER WINDOWS APP**

### **1. Task-Management**
- ✅ Tasks erstellen, bearbeiten, löschen
- ✅ Zeitbasierte Tasks
- ✅ Wiederkehrende Tasks
- ✅ Routinen

### **2. Blockierung**
- ✅ App-Blockierung (Windows Firewall)
- ✅ URL-Blockierung (Hosts-Datei)
- ✅ Blocklisten-Verwaltung
- ✅ Synchronisiert mit iPhone/Mac

### **3. Synchronisation**
- ✅ Firebase Real-time Sync
- ✅ Tasks, Routinen, Blocklisten
- ✅ Einstellungen

### **4. UI/UX**
- ✅ Gleiche UI wie PWA
- ✅ System Tray Integration
- ✅ Desktop Notifications
- ✅ Auto-Start Option

---

## 🚀 **ENTWICKLUNGSSCHRITTE**

### **Phase 1: Electron Setup**
1. Electron-Projekt erstellen
2. PWA-Code integrieren
3. Firebase SDK einrichten
4. Basic Window Management

### **Phase 2: Windows Blockierung**
1. Windows Firewall Integration
2. Hosts-Datei Manipulation
3. Admin-Rechte Handling
4. Blockierungs-UI

### **Phase 3: Native Features**
1. System Tray
2. Desktop Notifications
3. Auto-Start
4. Auto-Updater

### **Phase 4: Distribution**
1. Code Signing
2. Installer erstellen (NSIS/Inno Setup)
3. Auto-Updater konfigurieren
4. Windows Store (optional)

---

## 📦 **DISTRIBUTION**

### **Option A: Direct Download**
- Installer auf Website
- Auto-Updater für Updates
- Code Signing für Vertrauen

### **Option B: Windows Store**
- Microsoft Store Listing
- Automatische Updates
- Verifizierte App

### **Option C: GitHub Releases**
- GitHub Releases für Downloads
- Open Source möglich
- Community-driven

---

## 🔧 **TECHNISCHE DETAILS**

### **Windows Blockierung - Firewall**

```javascript
// Blockiere App
netsh advfirewall firewall add rule name="FocusCoach-Block-Instagram" dir=out action=block program="C:\Program Files\Instagram\Instagram.exe" enable=yes

// Entblocke App
netsh advfirewall firewall delete rule name="FocusCoach-Block-Instagram"

// Blockiere URL (Hosts-Datei)
127.0.0.1 instagram.com
127.0.0.1 www.instagram.com
```

### **Electron Main Process**

```javascript
// main.js
const { app, BrowserWindow } = require('electron');
const { WindowsFirewallBlocker } = require('./native/blocking/firewall');

let mainWindow;

app.whenReady().then(() => {
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });
    
    mainWindow.loadURL('http://localhost:3000'); // Oder PWA URL
    
    // IPC für Blockierung
    ipcMain.handle('block-app', async (event, appPath) => {
        return await WindowsFirewallBlocker.blockApp(appPath);
    });
});
```

---

## ✅ **NÄCHSTE SCHRITTE**

1. ✅ Electron-Projekt Setup
2. ⏳ PWA-Code integrieren
3. ⏳ Windows Firewall Integration
4. ⏳ System Tray
5. ⏳ Installer erstellen



