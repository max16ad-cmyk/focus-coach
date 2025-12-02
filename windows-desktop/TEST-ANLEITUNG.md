# 🧪 WINDOWS APP TEST-ANLEITUNG

## ✅ **WAS IST EINGERICHTET**

### **1. Electron App Struktur** ✅
- ✅ Main Process (`main/main.js`)
- ✅ Preload Script (`main/preload.js`)
- ✅ Windows Firewall Blockierung (`native/blocking/firewall.js`)
- ✅ Analytics Integration (`native/analytics.js`)

### **2. Analytics System** ✅
- ✅ Firebase Analytics Service (`services/analytics.ts`)
- ✅ iOS Analytics Service (`ios/FocusCoach/Services/AnalyticsService.swift`)
- ✅ Windows Analytics Integration
- ✅ Cross-Platform Activity Logging

### **3. Blockierung** ✅
- ✅ Windows Firewall Integration
- ✅ Hosts-Datei Blockierung
- ✅ App & URL Blocking

### **4. Integration** ✅
- ✅ Nutzt bestehende Web-App als Renderer
- ✅ Firebase Synchronisation
- ✅ System Tray (vorbereitet)

---

## 🚀 **SO TESTEST DU ES**

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

```bash
# Terminal 1: Web-App Development Server
cd /Users/maxjacob/Documents/focus-coach
npm run dev
```

**Erwartetes Ergebnis:**
- Server startet auf `http://localhost:3000`
- Web-App läuft im Browser

### **Schritt 3: Electron App starten**

```bash
# Terminal 2: Electron App
cd /Users/maxjacob/Documents/focus-coach/windows-desktop
npm run dev
```

**Erwartetes Ergebnis:**
- Electron-Fenster öffnet sich
- Lädt Web-App von `http://localhost:3000`
- Sieht aus wie Web-App, läuft aber als Desktop-App

---

## 🧪 **WAS TESTEN**

### **1. App startet**
- ✅ Electron-Fenster öffnet sich
- ✅ Web-App wird geladen
- ✅ Keine Fehler in Console

### **2. Firebase Integration**
- ✅ Login funktioniert
- ✅ Tasks werden synchronisiert
- ✅ Daten werden gespeichert

### **3. Blockierung (benötigt Admin-Rechte)**
- ✅ `window.electronAPI.checkAdminRights()` gibt `true` zurück
- ✅ `window.electronAPI.blockApp()` funktioniert
- ✅ `window.electronAPI.blockURL()` funktioniert

### **4. Analytics**
- ✅ Aktivitäten werden geloggt
- ✅ Firebase Collection `activities` wird erstellt
- ✅ Logs erscheinen in Firebase Console

### **5. System Tray**
- ✅ Tray Icon erscheint (wenn Icon vorhanden)
- ✅ Rechtsklick zeigt Menü
- ✅ Doppelklick öffnet App

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
- Prüfe `GoogleService-Info.plist` (iOS)
- Prüfe Firebase Config in `services/firebase.ts`

---

## 📊 **ANALYTICS TESTEN**

### **1. Activity Logging testen**

**In Web-App (Browser Console):**
```javascript
// Import analytics
import { logActivity } from './services/analytics';

// Log test activity
logActivity('user-id', 'windows', 'app_blocked', {
    appName: 'TestApp',
    appPath: 'C:\\Test\\App.exe'
});
```

**In Electron (Renderer Console):**
```javascript
// Nutze electronAPI
window.electronAPI.logActivity({
    platform: 'windows',
    event: 'app_blocked',
    data: {
        appName: 'TestApp',
        appPath: 'C:\\Test\\App.exe'
    }
});
```

### **2. Analytics abrufen**

```javascript
import { getDailyAnalytics } from './services/analytics';

const summary = await getDailyAnalytics('user-id');
console.log('Daily Summary:', summary);
```

---

## 🎯 **PRODUCTION BUILD TESTEN**

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

### **3. Installer testen**
- `windows-desktop/dist/FocusCoach-Setup-1.0.0.exe` ausführen
- Installation durchführen
- App starten

---

## ✅ **CHECKLISTE**

- [ ] Dependencies installiert
- [ ] Web-App läuft (`npm run dev`)
- [ ] Electron App startet (`npm run dev` in windows-desktop)
- [ ] Firebase Login funktioniert
- [ ] Tasks werden synchronisiert
- [ ] Blockierung funktioniert (mit Admin-Rechten)
- [ ] Analytics werden geloggt
- [ ] System Tray erscheint
- [ ] Production Build funktioniert

---

## 📝 **NÄCHSTE SCHRITTE**

1. ⏳ Icon erstellen (`icon.ico` und `icon.png`)
2. ⏳ Code Signing einrichten (optional)
3. ⏳ Auto-Updater konfigurieren
4. ⏳ Installer testen
5. ⏳ Download-Seite erstellen




