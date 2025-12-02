# 🔒 APP & WEBSITE BLOCKING - IMPLEMENTATION PLAN

## 🎯 **ÜBERSICHT**

Die Hauptfunktion der Focus Coach App ist die **100% Blockierung von Apps und Websites** während aktiver Tasks. Dies wird über die **Screen Time API** von Apple realisiert.

---

## 📋 **ARCHITEKTUR**

### **1. Screen Time API (Apple's Native Solution)**

**Warum Screen Time API?**
- ✅ System-Level Blockierung (kann nicht umgangen werden)
- ✅ Funktioniert für ALLE Apps
- ✅ App Store approved
- ✅ Wie Opal & One Sec

**Technische Anforderungen:**
- `FamilyControls` Framework
- `ManagedSettings` Framework
- Screen Time Authorization
- iOS 15+ erforderlich

---

## 🏗️ **IMPLEMENTIERUNGS-PHASEN**

### **PHASE 1: Grundlegende Blockierung** ⭐ (Priorität 1)

**Was wird gebaut:**
1. **BlockingService** - Core Service für Blockierung
   - Authorization Handling
   - App Token Management
   - Blocking Logic (Apps + Websites)
   - Unblocking Logic

2. **App Selection UI**
   - `FamilyActivityPicker` Integration
   - App-Auswahl Interface
   - Visual Feedback

3. **Blocking Settings View**
   - Liste blockierter Apps
   - Website-Blockierung Toggle
   - Blockierung aktivieren/deaktivieren

**Zeit:** ~2-3 Stunden

---

### **PHASE 2: Zeitbasierte Blockierung** (Priorität 2)

**Was wird gebaut:**
- Blockierung nur während aktiver Tasks
- Automatisches Blockieren bei Task-Start
- Automatisches Entblocken bei Task-Ende
- Integration mit Task-Zeitfenstern

**Zeit:** ~1-2 Stunden

---

### **PHASE 3: Firebase Synchronisation** (Priorität 3)

**Was wird gebaut:**
- Blocked Apps in Firestore speichern
- Sync zwischen Geräten
- Backup & Restore

**Zeit:** ~1 Stunde

---

## 🔧 **TECHNISCHE DETAILS**

### **BlockingService Struktur:**

```swift
class BlockingService: ObservableObject {
    // Authorization
    func requestAuthorization() async throws
    
    // App Blocking
    func blockApps(_ tokens: Set<ApplicationToken>)
    func unblockApps()
    func getBlockedApps() -> Set<ApplicationToken>
    
    // Website Blocking
    func blockWebsites(_ mode: WebContentFilterMode)
    func unblockWebsites()
    
    // Task-based Blocking
    func startTaskBlocking(task: Task)
    func stopTaskBlocking()
}
```

### **UI Komponenten:**

1. **AppSelectionView**
   - `FamilyActivityPicker` für App-Auswahl
   - Liste ausgewählter Apps
   - Entfernen-Funktion

2. **BlockingSettingsView**
   - Toggle für App-Blockierung
   - Toggle für Website-Blockierung
   - Status-Anzeige

3. **TaskBlockingIndicator**
   - Zeigt an, ob Blockierung aktiv ist
   - Visuelles Feedback während Tasks

---

## 📱 **USER FLOW**

### **Erstmalige Einrichtung:**

1. User öffnet Blocking Settings
2. App fragt nach Screen Time Authorization
3. User wählt Apps aus (FamilyActivityPicker)
4. User aktiviert Blockierung
5. Apps sind jetzt blockiert ✅

### **Während eines Tasks:**

1. User startet Task mit Zeitfenster
2. Blockierung wird automatisch aktiviert
3. Apps sind während Task blockiert
4. Task endet → Blockierung wird deaktiviert

### **Manuelle Blockierung:**

1. User öffnet Blocking Settings
2. User aktiviert/deaktiviert Blockierung
3. Änderungen werden sofort angewendet

---

## ⚠️ **WICHTIGE HINWEISE**

### **Limitations:**
- Screen Time API benötigt iOS 15+
- User muss Screen Time aktivieren
- Authorization kann nur einmal pro App-Session angefordert werden
- App Tokens können nicht direkt gespeichert werden (Privacy)

### **Best Practices:**
- Authorization früh anfordern
- User über Blockierung informieren
- Klare UI für Blockierung-Status
- Graceful Fallback wenn Authorization fehlt

---

## 🚀 **NÄCHSTE SCHRITTE**

1. ✅ BlockingService erstellen
2. ✅ App Selection UI implementieren
3. ✅ Blocking Settings View erstellen
4. ✅ Integration mit Task-System
5. ✅ Firebase Sync hinzufügen

---

## 📚 **QUELLEN**

- [Apple Family Controls Documentation](https://developer.apple.com/documentation/familycontrols)
- [ManagedSettings Documentation](https://developer.apple.com/documentation/managedsettings)
- [Screen Time API Guide](https://developer.apple.com/documentation/familycontrols/setting_up_a_family_controls_app)





