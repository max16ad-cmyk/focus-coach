# 🔒 BLOCKIERUNG-ARCHITEKTUR - VOLLSTÄNDIGE ERKLÄRUNG

## 📋 **ÜBERSICHT**

Die App-Blockierung funktioniert über **Apple's Screen Time API** (FamilyControls & ManagedSettings). Dies ist die einzige Möglichkeit, Apps systemweit auf iOS zu blockieren.

---

## 🎯 **AKTUELLER AUFBAU**

### **1. SPEICHERUNG DER BLOCKLISTEN**

#### **Apps (ApplicationTokens):**
- **Wo gespeichert:** `UserDefaults.standard` unter dem Key `"blockedAppsSelection"`
- **Format:** `FamilyActivitySelection` (von Apple's FamilyControls Framework)
- **Datei:** `BlockingService.swift` → `storeSelection()` / `loadStoredSelection()`
- **Wichtig:** Apple erlaubt es NICHT, die Namen der Apps zu speichern (Privacy). Nur anonyme Tokens!

```swift
// BlockingService.swift - Zeile 451-461
func storeSelection(_ selection: FamilyActivitySelection) {
    let encoder = JSONEncoder()
    let data = try encoder.encode(selection)
    UserDefaults.standard.set(data, forKey: "blockedAppsSelection")
    // ...
}
```

#### **URLs (Websites):**
- **Wo gespeichert:** 
  - Lokal: `BlockingService.blockedURLs` (Array von Strings)
  - App Group: `UserDefaults(suiteName: "group.com.focuscoach.blocking")` für Content Blocker Extension
- **Format:** Array von Domain-Strings (z.B. `["youtube.com", "instagram.com"]`)
- **Datei:** `BlockingService.swift` → `blockSpecificWebsites()`

```swift
// BlockingService.swift - Zeile 297-322
func blockSpecificWebsites(_ domains: [String]) {
    blockedURLs = domains
    // Speichere in App Group für Content Blocker Extension
    if let sharedDefaults = UserDefaults(suiteName: "group.com.focuscoach.blocking") {
        sharedDefaults.set(domains, forKey: "blockedURLs")
    }
}
```

---

## ⚙️ **WIE DIE BLOCKIERUNG AUSGELÖST WIRD**

### **TRIGGER: TaskBlockingMonitor**

Die Blockierung wird automatisch aktiviert, wenn **aktive Tasks** vorhanden sind.

#### **Schritt-für-Schritt Ablauf:**

1. **TaskBlockingMonitor startet:**
   ```swift
   // TaskBlockingMonitor.swift - Zeile 23-32
   private init() {
       // Hört auf Änderungen in TaskRepository
       taskRepository.$allTasks
           .sink { [weak self] _ in
               self?.checkActiveTasks()
           }
       startMonitoring() // Timer alle 30 Sekunden
   }
   ```

2. **Prüfung alle 30 Sekunden:**
   ```swift
   // TaskBlockingMonitor.swift - Zeile 60-115
   func checkActiveTasks() {
       // 1. Lade alle Tasks für heute
       let allTasks = taskRepository.getTasksForToday()
       
       // 2. Filtere aktive Tasks:
       //    - Nicht erledigt (completed = false)
       //    - Entweder: Keine Zeitangabe (immer blockieren)
       //    - Oder: Aktuelle Zeit liegt zwischen startTime und endTime
       
       // 3. Wenn aktive Tasks vorhanden:
       if !active.isEmpty {
           // Aktiviere Blockierung
           blockingService.blockApps(blockingService.familyActivitySelection.applicationTokens)
       } else {
           // Deaktiviere Blockierung
           blockingService.unblockApps()
       }
   }
   ```

3. **Blockierung wird aktiviert:**
   ```swift
   // BlockingService.swift - Zeile 125-140
   func blockApps(_ tokens: Set<ApplicationToken>) {
       blockedAppTokens = tokens
       store.shield.applications = tokens  // ← HIER PASSIERT DIE BLOCKIERUNG!
       isBlockingActive = true
   }
   ```

4. **System-Level Blockierung:**
   - `ManagedSettingsStore.shield.applications` wird gesetzt
   - iOS blockiert die Apps **systemweit**
   - User kann die Apps **nicht öffnen** (auch nicht durch Umgehung)

---

## 🔄 **KOMPLETTER ABLAUF (VISUELL)**

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USER ERSTELLT TASK                                        │
│    "Morgen 17:00 Formel 1 gucken"                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. TaskRepository speichert Task                           │
│    - scheduledDate: "2025-11-30"                           │
│    - scheduledStartTime: "17:00"                           │
│    - completed: false                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. TaskBlockingMonitor.checkActiveTasks()                    │
│    - Wird alle 30 Sekunden aufgerufen                       │
│    - Prüft: Ist aktuelle Zeit zwischen 17:00-18:00?        │
│    - Prüft: Ist Task erledigt?                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Wenn Task AKTIV:                                          │
│    blockingService.blockApps(tokens)                         │
│    ↓                                                          │
│    ManagedSettingsStore.shield.applications = tokens        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. iOS BLOCKIERT APPS SYSTEMWEIT                            │
│    - User versucht Instagram zu öffnen                      │
│    - iOS zeigt Blockierungsseite                            │
│    - App kann NICHT geöffnet werden                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 **WAS WIRD GESPEICHERT?**

### **Aktuell (EINE Blockliste):**

| Daten | Speicherort | Format | Key |
|-------|-------------|--------|-----|
| **Apps** | `UserDefaults.standard` | `FamilyActivitySelection` (JSON) | `"blockedAppsSelection"` |
| **URLs** | `BlockingService.blockedURLs` | `[String]` | In-Memory + App Group |
| **Block Screen Style** | `UserDefaults.standard` | `CustomBlockScreen` (JSON) | `"customBlockScreen"` |
| **Auto-Rotate Setting** | `UserDefaults.standard` | `Bool` | `"autoRotateBlockScreenBackgrounds"` |

### **WICHTIG:**
- **Apps:** Nur anonyme Tokens werden gespeichert (Apple Privacy Policy)
- **URLs:** Werden als Domain-Strings gespeichert
- **NICHT in Firebase:** Aktuell werden Blocklisten nur lokal gespeichert!

---

## 🎯 **WAS DU DIR VORGESTELLT HAST**

Du möchtest:
- ✅ **Verschiedene Blocklisten erstellen können**
- ✅ **Für Apps UND URLs**
- ✅ **Diese Blocklisten speichern und später verwenden**

### **Beispiel:**
```
Blockliste 1: "Social Media"
  - Apps: Instagram, TikTok, Twitter
  - URLs: instagram.com, tiktok.com, twitter.com

Blockliste 2: "Entertainment"
  - Apps: YouTube, Netflix, Spotify
  - URLs: youtube.com, netflix.com, spotify.com

Blockliste 3: "Arbeit"
  - Apps: Slack, Teams
  - URLs: slack.com, teams.microsoft.com
```

---

## 🚀 **VORSCHLAG: ERWEITERTE ARCHITEKTUR**

### **Neues Modell: BlockList**

```swift
struct BlockList: Identifiable, Codable {
    let id: String
    var name: String
    var appTokens: Set<ApplicationToken>  // Für Apps
    var urls: [String]                     // Für URLs
    var createdAt: Date
    var updatedAt: Date
}

// In BlockingService:
@Published var blockLists: [BlockList] = []
@Published var activeBlockList: BlockList?
```

### **Speicherung:**

1. **Lokal (UserDefaults):**
   ```swift
   // Speichere alle Blocklisten
   UserDefaults.standard.set(encodedBlockLists, forKey: "blockLists")
   ```

2. **Firebase (Optional - für Sync):**
   ```swift
   // Synchronisiere mit anderen Geräten
   FirebaseService.shared.saveBlockLists(blockLists)
   ```

### **Verwendung:**

```swift
// User wählt Blockliste aus
func activateBlockList(_ blockList: BlockList) {
    activeBlockList = blockList
    blockApps(blockList.appTokens)
    blockSpecificWebsites(blockList.urls)
}
```

---

## 📝 **ZUSAMMENFASSUNG**

### **Aktuell:**
- ✅ **EINE** Blockliste für Apps (FamilyActivitySelection)
- ✅ **EINE** Liste für URLs
- ✅ Blockierung wird durch **TaskBlockingMonitor** getriggert
- ✅ Speicherung nur **lokal** (UserDefaults)

### **Was fehlt:**
- ❌ Mehrere Blocklisten können nicht erstellt werden
- ❌ Blocklisten können nicht benannt werden
- ❌ Blocklisten werden nicht in Firebase synchronisiert
- ❌ Keine Möglichkeit, Blocklisten zu organisieren

### **Nächste Schritte:**
1. **BlockList Modell erstellen**
2. **BlockListRepository** für Verwaltung
3. **UI für Blocklisten-Verwaltung** (Erstellen, Bearbeiten, Löschen)
4. **Integration mit TaskBlockingMonitor** (Blockliste pro Task?)
5. **Optional: Firebase Sync** für Multi-Device

---

## 🔍 **WICHTIGE DATEIEN**

| Datei | Zweck |
|-------|-------|
| `BlockingService.swift` | Haupt-Service für Blockierung |
| `TaskBlockingMonitor.swift` | Überwacht Tasks und triggert Blockierung |
| `BlockingSettingsView.swift` | UI für Blockierungs-Einstellungen |
| `CategorizedAppPickerView.swift` | UI für App-Auswahl |

---

## ❓ **OFFENE FRAGEN**

1. **Soll jede Blockliste einem Task zugeordnet werden können?**
   - Beispiel: Task "Lernen" → Blockliste "Social Media"
   
2. **Sollen Blocklisten in Firebase synchronisiert werden?**
   - Für Multi-Device Support
   
3. **Soll es eine Standard-Blockliste geben?**
   - Die automatisch verwendet wird, wenn keine spezifische zugeordnet ist



