# 🚀 WINDOWS APP QUICK START GUIDE

## ✅ **WAS DIE APP KANN**

### **1. App-Blockierung** 🛡️
- Blockiert Apps über **Windows Firewall**
- Apps können nicht gestartet werden
- System-Level Blockierung (kann nicht umgangen werden)
- **Benötigt Admin-Rechte**

### **2. URL-Blockierung** 🌐
- Blockiert Websites über **Hosts-Datei**
- Funktioniert in allen Browsern
- Leitet blockierte Domains auf `127.0.0.1` um
- **Benötigt Admin-Rechte**

### **3. Firebase Synchronisation** ☁️
- Tasks, Routinen, Settings werden synchronisiert
- Echtzeit-Sync mit iOS-App und Web-App
- Gleiche User-Accounts über alle Plattformen

### **4. Analytics & Logging** 📊
- Loggt alle Blockierungen
- Loggt Task-Completions
- Speichert in Firebase Firestore
- Cross-Platform Analytics

### **5. System Tray** 🔔
- Minimiert in System Tray
- Rechtsklick-Menü
- Doppelklick öffnet App
- Läuft im Hintergrund

---

## 🧪 **SO TESTEST DU ES**

### **Schritt 1: Dependencies installieren**

```bash
# Im Hauptverzeichnis
cd /Users/maxjacob/Documents/focus-coach
npm install

# Windows Desktop App
cd windows-desktop
npm install
```

### **Schritt 2: Web-App starten**

**Terminal 1:**
```bash
cd /Users/maxjacob/Documents/focus-coach
npm run dev
```

**Erwartung:** Server läuft auf `http://localhost:3000`

### **Schritt 3: Electron App starten**

**Terminal 2:**
```bash
cd /Users/maxjacob/Documents/focus-coach/windows-desktop
npm run dev
```

**Erwartung:**
- ✅ Electron-Fenster öffnet sich
- ✅ Lädt Web-App von `http://localhost:3000`
- ✅ DevTools sind geöffnet
- ✅ Sieht aus wie Web-App, läuft aber als Desktop-App

---

## 🧪 **WAS TESTEN**

### **1. App startet** ✅
- [ ] Electron-Fenster öffnet sich
- [ ] Web-App wird geladen
- [ ] Keine Fehler in Console

### **2. Firebase Integration** ✅
- [ ] Login funktioniert
- [ ] Tasks werden synchronisiert
- [ ] Daten werden gespeichert

### **3. Blockierung testen** (benötigt Admin-Rechte)

**In Electron Console (DevTools):**

```javascript
// 1. Admin-Rechte prüfen
await window.electronAPI.checkAdminRights()
// Erwartung: { hasAdmin: true/false }

// 2. App blockieren
await window.electronAPI.blockApp('C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe', 'Chrome')
// Erwartung: { success: true }

// 3. URL blockieren
await window.electronAPI.blockURL('instagram.com')
// Erwartung: { success: true }

// 4. Blockierte Apps anzeigen
await window.electronAPI.getBlockedApps()
// Erwartung: { success: true, apps: [...] }

// 5. App entblocken
await window.electronAPI.unblockApp('Chrome')
// Erwartung: { success: true }

// 6. URL entblocken
await window.electronAPI.unblockURL('instagram.com')
// Erwartung: { success: true }
```

### **4. Analytics testen**

```javascript
// Activity loggen
await window.electronAPI.logActivity({
    platform: 'windows',
    event: 'app_blocked',
    data: {
        appName: 'Chrome',
        appPath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
    }
})
```

### **5. System Tray** ✅
- [ ] Tray Icon erscheint (wenn Icon vorhanden)
- [ ] Rechtsklick zeigt Menü
- [ ] Doppelklick öffnet App
- [ ] App minimiert in Tray

---

## 🔍 **DEBUGGING**

### **Console Logs ansehen**

**In Electron:**
- DevTools sind automatisch geöffnet (Development)
- `View → Toggle Developer Tools` (Production)

**In Web-App:**
- Browser Console (wenn Web-App direkt im Browser läuft)

### **Häufige Probleme**

**1. "Cannot find module 'electron'"**
```bash
cd windows-desktop
npm install
```

**2. "Web-App lädt nicht"**
- Stelle sicher, dass `npm run dev` im Hauptverzeichnis läuft
- Prüfe ob `http://localhost:3000` erreichbar ist

**3. "Admin-Rechte fehlen"**
- Windows: App als Administrator starten
- Oder: Installer mit Admin-Rechten ausführen

**4. "Firebase nicht initialisiert"**
- Prüfe Firebase Config in `services/firebase.ts`
- Stelle sicher, dass Login funktioniert

---

## 📋 **VERFÜGBARE API-FUNKTIONEN**

### **Blocking API**
```javascript
// App blockieren
window.electronAPI.blockApp(appPath, appName)

// App entblocken
window.electronAPI.unblockApp(appName)

// URL blockieren
window.electronAPI.blockURL(domain)

// URL entblocken
window.electronAPI.unblockURL(domain)

// Blockierte Apps anzeigen
window.electronAPI.getBlockedApps()
```

### **Analytics API**
```javascript
// Activity loggen
window.electronAPI.logActivity({
    platform: 'windows',
    event: 'app_blocked' | 'url_blocked' | 'task_completed',
    data: { ... }
})
```

### **System API**
```javascript
// Admin-Rechte prüfen
window.electronAPI.checkAdminRights()

// Platform Info
window.electronAPI.platform  // 'win32' | 'darwin' | 'linux'
window.electronAPI.isWindows // true/false
```

---

## 🎯 **PRODUCTION BUILD**

### **1. Web-App bauen**
```bash
cd /Users/maxjacob/Documents/focus-coach
npm run build
```

### **2. Windows-App bauen**
```bash
cd windows-desktop
npm run build
```

### **3. Installer erstellen**
```bash
npm run dist
```

**Ergebnis:** `windows-desktop/dist/FocusCoach-Setup-1.0.0.exe`

---

## ✅ **CHECKLISTE**

- [ ] Dependencies installiert (`npm install` in beiden Verzeichnissen)
- [ ] Web-App läuft (`npm run dev` im Hauptverzeichnis)
- [ ] Electron App startet (`npm run dev` in windows-desktop)
- [ ] Login funktioniert
- [ ] Tasks werden synchronisiert
- [ ] Blockierung funktioniert (mit Admin-Rechten)
- [ ] Analytics werden geloggt
- [ ] System Tray erscheint

---

## 🎉 **FERTIG!**

Die Windows Desktop App ist jetzt einsatzbereit! 

**Nächste Schritte:**
1. Icon erstellen (`windows-desktop/assets/icon.ico`)
2. Production Build testen
3. Installer verteilen



