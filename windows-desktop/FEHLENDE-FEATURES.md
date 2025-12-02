# 🚧 FEHLENDE FEATURES - WINDOWS APP

## 📋 **ÜBERSICHT**

Die Windows-App hat bereits die Grundstruktur, aber es fehlen noch wichtige Integrationen und Features, damit sie vollständig funktioniert.

---

## ❌ **WAS NOCH FEHLT**

### **1. 🔗 WEB-APP INTEGRATION MIT ELECTRON-API** ⚠️ **KRITISCH**

**Problem:**
- Die Web-App nutzt `window.electronAPI` noch nicht
- Blockierung wird nicht automatisch während Tasks aktiviert
- Keine Verbindung zwischen Task-Management und Blockierung

**Was fehlt:**
- ✅ Service/Hook für Electron-API Integration
- ✅ Automatische Blockierung wenn Task aktiv ist
- ✅ Automatische Entblockung wenn Task beendet ist
- ✅ Blocklisten-Verwaltung nutzt Electron-API

**Dateien die erstellt/geändert werden müssen:**
```
services/
└── electronService.ts          ❌ FEHLT - Electron API Wrapper

hooks/
└── useElectronBlocking.ts     ❌ FEHLT - Hook für Blockierung

components/
└── BlockingSettings.tsx       ❌ FEHLT - UI für Blocklisten-Verwaltung
```

---

### **2. 🎯 AUTOMATISCHE TASK-BASIERTE BLOCKIERUNG** ⚠️ **KRITISCH**

**Problem:**
- Apps werden nicht automatisch blockiert wenn Task startet
- URLs werden nicht automatisch blockiert während Task aktiv ist
- Blockierung bleibt aktiv auch wenn kein Task läuft

**Was fehlt:**
- ✅ Task-Start erkennt aktive Tasks
- ✅ Blockiert automatisch Apps aus Blockliste
- ✅ Blockiert automatisch URLs aus Blockliste
- ✅ Entblockt automatisch wenn Task beendet
- ✅ Prüft ob Task aktiv ist (Startzeit/Endzeit)

**Integration:**
```typescript
// In PremiumActiveDay.tsx oder useTaskHandlers.ts
useEffect(() => {
  if (activeTask && window.electronAPI?.isWindows) {
    // Blockiere Apps und URLs
    blockTaskDistractions(activeTask.blocklist);
  }
}, [activeTask]);
```

---

### **3. 📱 BLOCKLISTEN-VERWALTUNG UI** ⚠️ **WICHTIG**

**Problem:**
- Keine UI zum Verwalten von Blocklisten in Windows-App
- User kann Apps/URLs nicht hinzufügen/entfernen
- Keine Vorschau welche Apps/URLs blockiert sind

**Was fehlt:**
- ✅ Komponente für Blocklisten-Verwaltung
- ✅ App-Auswahl (z.B. aus installierten Apps)
- ✅ URL-Eingabe
- ✅ Liste der blockierten Apps/URLs
- ✅ Test-Funktion (App öffnen testen)

**Neue Komponente:**
```typescript
// components/BlockingSettings.tsx
- App-Liste anzeigen
- Apps hinzufügen/entfernen
- URLs hinzufügen/entfernen
- Admin-Rechte prüfen
- Blockierung testen
```

---

### **4. 🔔 NOTIFICATION SYSTEM** ⚠️ **WICHTIG**

**Problem:**
- Keine Desktop-Benachrichtigungen
- User wird nicht informiert wenn Blockierung aktiviert wird
- Keine Erinnerungen für Tasks

**Was fehlt:**
- ✅ Desktop Notifications API
- ✅ Notification wenn Task startet
- ✅ Notification wenn Blockierung aktiviert wird
- ✅ Notification wenn Task beendet ist
- ✅ Notification für Task-Erinnerungen

**Integration:**
```javascript
// In main.js
const { Notification } = require('electron');

function showNotification(title, body) {
  new Notification({ title, body }).show();
}
```

---

### **5. 🚀 AUTO-START FEATURE** ⚠️ **OPTIONAL**

**Problem:**
- App startet nicht automatisch beim Windows-Start
- User muss App manuell starten

**Was fehlt:**
- ✅ Auto-Start Option in Settings
- ✅ Windows Registry Eintrag für Auto-Start
- ✅ UI-Toggle für Auto-Start

**Integration:**
```javascript
// In main.js
const { app } = require('electron');
app.setLoginItemSettings({
  openAtLogin: true,
  name: 'FocusCoach'
});
```

---

### **6. 🎨 ICON-DATEIEN** ⚠️ **OPTIONAL**

**Problem:**
- Icon-Dateien fehlen noch
- App hat Standard-Electron-Icon

**Was fehlt:**
- ✅ `icon.ico` für Windows
- ✅ `icon.png` für System Tray
- ✅ Icon-Design erstellen

**Siehe:** `windows-desktop/assets/ICON-ANLEITUNG.md`

---

### **7. 🔍 APP-ERKENNUNG** ⚠️ **WICHTIG**

**Problem:**
- User muss App-Pfad manuell eingeben
- Keine automatische Erkennung installierter Apps
- Keine App-Liste zur Auswahl

**Was fehlt:**
- ✅ Windows Registry lesen für installierte Apps
- ✅ App-Liste generieren
- ✅ App-Pfad automatisch finden
- ✅ UI für App-Auswahl

**Integration:**
```javascript
// native/app-discovery.js
const { exec } = require('child_process');

async function getInstalledApps() {
  // Lesen aus Registry
  // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
}
```

---

### **8. ⚡ PERFORMANCE & FEHLERBEHANDLUNG** ⚠️ **WICHTIG**

**Problem:**
- Keine Fehlerbehandlung für Blockierung
- Keine Retry-Logik wenn Admin-Rechte fehlen
- Keine Logging-Funktion

**Was fehlt:**
- ✅ Error Handling für Firewall-Befehle
- ✅ Retry-Logik
- ✅ Logging-System
- ✅ User-Feedback bei Fehlern

---

### **9. 🔄 SYNCHRONISATION MIT FIREBASE** ✅ **TEILWEISE VORHANDEN**

**Status:**
- ✅ Firebase Service vorhanden
- ✅ Analytics Service vorhanden
- ⚠️ Blocklisten werden noch nicht mit Firebase synchronisiert

**Was fehlt:**
- ✅ Blocklisten in Firestore speichern
- ✅ Blocklisten zwischen Geräten synchronisieren
- ✅ Real-time Updates für Blocklisten

---

### **10. 🧪 TESTING & DEBUGGING** ⚠️ **WICHTIG**

**Problem:**
- Keine Test-Funktionen
- Schwer zu debuggen wenn Blockierung nicht funktioniert

**Was fehlt:**
- ✅ Test-Modus (Blockierung ohne Admin-Rechte simulieren)
- ✅ Debug-Logging
- ✅ Blockierung-Status anzeigen
- ✅ Test-Button für Blockierung

---

## 📊 **PRIORITÄTEN**

### **🔴 KRITISCH (Muss sofort implementiert werden):**
1. ✅ Web-App Integration mit Electron-API
2. ✅ Automatische Task-basierte Blockierung
3. ✅ Blocklisten-Verwaltung UI

### **🟡 WICHTIG (Sollte bald implementiert werden):**
4. ✅ Notification System
5. ✅ App-Erkennung
6. ✅ Performance & Fehlerbehandlung
7. ✅ Blocklisten-Synchronisation mit Firebase

### **🟢 OPTIONAL (Kann später implementiert werden):**
8. ✅ Auto-Start Feature
9. ✅ Icon-Dateien
10. ✅ Testing & Debugging Tools

---

## 🛠️ **NÄCHSTE SCHRITTE**

### **Schritt 1: Electron Service erstellen**
```typescript
// services/electronService.ts
export const electronService = {
  isElectron: typeof window !== 'undefined' && window.electronAPI,
  
  async blockApp(appPath: string, appName: string) {
    if (!this.isElectron) return;
    return await window.electronAPI.blockApp(appPath, appName);
  },
  
  // ... weitere Methoden
};
```

### **Schritt 2: Blocking Hook erstellen**
```typescript
// hooks/useElectronBlocking.ts
export function useElectronBlocking() {
  const blockApps = async (apps: string[]) => {
    // Blockiere alle Apps
  };
  
  const blockURLs = async (urls: string[]) => {
    // Blockiere alle URLs
  };
  
  return { blockApps, blockURLs };
}
```

### **Schritt 3: Task-Integration**
```typescript
// In PremiumActiveDay.tsx
useEffect(() => {
  if (activeTask && electronService.isElectron) {
    // Blockiere Distractions
    blockTaskDistractions(activeTask.blocklist);
  }
}, [activeTask]);
```

---

## 📝 **ZUSAMMENFASSUNG**

**Was bereits funktioniert:**
- ✅ Electron Setup
- ✅ Windows Firewall Blockierung (Backend)
- ✅ Analytics Integration
- ✅ System Tray
- ✅ Preload Script

**Was noch fehlt:**
- ❌ Web-App nutzt Electron-API nicht
- ❌ Keine automatische Blockierung während Tasks
- ❌ Keine UI für Blocklisten-Verwaltung
- ❌ Keine Notifications
- ❌ Keine App-Erkennung

**Geschätzter Aufwand:**
- Kritische Features: ~4-6 Stunden
- Wichtige Features: ~3-4 Stunden
- Optionale Features: ~2-3 Stunden

**Gesamt: ~9-13 Stunden Entwicklungszeit**

