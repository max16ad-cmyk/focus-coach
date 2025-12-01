# 🌐 MULTI-PLATFORM BLOCKING - ARCHITEKTUR PLAN

## 🎯 **ÜBERSICHT**

Synchronisierte Blockierung über alle Geräte:
- ✅ **iPhone/iPad** - Screen Time API (bereits implementiert)
- ✅ **Mac** - Screen Time API (macOS 12+)
- ⚠️ **Windows PC** - Windows Parental Controls / Firewall
- ⚠️ **Web/PWA** - Browser Extension (Chrome, Edge, Firefox)

---

## 📊 **ARCHITEKTUR**

### **1. Firebase-Synchronisation**

```
┌─────────────┐
│   iPhone    │
│  (Screen    │
│   Time)     │
└──────┬──────┘
       │
       │ Firebase Firestore
       │ (Real-time Sync)
       │
┌──────┴──────┐
│             │
│  Firebase   │
│  Firestore  │
│             │
└──────┬──────┘
       │
       ├──────────┬──────────┬──────────┐
       │          │          │          │
┌──────▼──────┐ ┌▼──────┐ ┌▼──────┐ ┌▼──────┐
│    Mac      │ │ iPad  │ │  PC   │ │  Web  │
│  (Screen    │ │(Screen│ │(Windows│ │(Browser│
│   Time)     │ │ Time) │ │Parental│ │Ext.)  │
└─────────────┘ └───────┘ └───────┘ └───────┘
```

### **2. Datenstruktur in Firebase**

```json
{
  "users/{userId}/blockLists": {
    "blockListId": {
      "id": "uuid",
      "name": "Standard",
      "urls": ["youtube.com", "instagram.com"],
      "appIdentifiers": {
        "ios": ["com.instagram.instagram", "com.tiktok.TikTok"],
        "macos": ["com.instagram.instagram", "com.tiktok.TikTok"],
        "windows": ["Instagram.exe", "TikTok.exe"],
        "web": ["instagram.com", "tiktok.com"]
      },
      "isDefault": true,
      "createdAt": 1234567890,
      "updatedAt": 1234567890
    }
  }
}
```

---

## 🔧 **PLATTFORM-SPEZIFISCHE IMPLEMENTIERUNG**

### **1. iOS/iPad (bereits implementiert)**
- ✅ Screen Time API (`FamilyControls` + `ManagedSettings`)
- ✅ `ApplicationToken` für Apps
- ✅ Safari Content Blocker für URLs

### **2. macOS (macOS 12+)**
- ✅ Screen Time API (gleiche API wie iOS)
- ✅ `FamilyControls` + `ManagedSettings`
- ✅ Funktioniert identisch wie iOS

### **3. Windows PC**
- ⚠️ **Option A: Windows Parental Controls**
  - Windows Family Safety API
  - Benötigt Microsoft Account
  - System-Level Blockierung
  
- ⚠️ **Option B: Windows Firewall**
  - Blockiert Netzwerk-Verbindungen
  - Funktioniert für Browser-Apps
  - Nicht für native Apps

- ⚠️ **Option C: Browser Extension**
  - Chrome/Edge Extension
  - Blockiert nur im Browser
  - Einfachste Lösung

### **4. Web/PWA**
- ⚠️ **Browser Extension**
  - Chrome Extension (Content Scripts)
  - Edge Extension (gleiche API)
  - Firefox Extension (WebExtensions API)
  - Safari Extension (Content Blocker)

---

## 📝 **IMPLEMENTIERUNG SCHRITTE**

### **Phase 1: Firebase-Sync für Blocklisten** ✅
1. `FirebaseService.saveBlockList()` - Speichere Blockliste
2. `FirebaseService.subscribeToBlockLists()` - Real-time Sync
3. `BlockListRepository` erweitern für Firebase

### **Phase 2: Plattform-spezifische App-Identifikatoren**
1. `BlockList` erweitern mit `appIdentifiers` (iOS, macOS, Windows, Web)
2. Konvertierung zwischen Plattformen
3. Mapping von Bundle IDs zu App-Namen

### **Phase 3: Mac-Implementierung**
1. Gleiche Screen Time API wie iOS
2. Universal Binary (iOS + macOS)
3. iCloud Sync über Firebase

### **Phase 4: Windows-Implementierung**
1. Windows Parental Controls API
2. Oder Browser Extension
3. Oder Windows Firewall

### **Phase 5: Web/PWA**
1. Browser Extension entwickeln
2. Content Scripts für URL-Blockierung
3. Chrome Web Store / Edge Add-ons

---

## 🔄 **SYNCHRONISATIONS-FLOW**

```
1. User wählt Apps auf iPhone aus
   ↓
2. BlockListRepository speichert lokal (UserDefaults)
   ↓
3. FirebaseService.saveBlockList() → Firebase Firestore
   ↓
4. Firebase sendet Update an alle Geräte (< 1 Sekunde)
   ↓
5. Mac/iPad/PC/Web empfängt Update
   ↓
6. Plattform-spezifische Blockierung wird aktiviert
```

---

## 📱 **PLATTFORM-DETAILS**

### **macOS**
- Gleiche API wie iOS
- `FamilyControls` + `ManagedSettings`
- Funktioniert ab macOS 12.0+
- Universal Binary möglich

### **Windows**
- Windows Parental Controls API (komplex)
- Oder Browser Extension (einfacher)
- Oder Windows Firewall (System-Level)

### **Web**
- Browser Extension (Chrome, Edge, Firefox)
- Content Scripts blockieren URLs
- Keine App-Blockierung möglich (Browser-Limitierung)

---

## ✅ **NÄCHSTE SCHRITTE**

1. ✅ Firebase-Sync für Blocklisten implementieren
2. ⏳ BlockList-Modell erweitern für Multi-Platform
3. ⏳ Mac-Implementierung (gleiche API)
4. ⏳ Windows-Implementierung planen
5. ⏳ Browser Extension entwickeln



