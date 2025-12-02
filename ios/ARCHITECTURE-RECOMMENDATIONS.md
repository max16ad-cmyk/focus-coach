# 🏗️ ARCHITEKTUR-EMPFEHLUNGEN FÜR FOCUS COACH

## 📋 **ÜBERSICHT**

Dieses Dokument beschreibt Empfehlungen für eine stabilere und wartbarere App-Architektur.

---

## 🎯 **1. ZENTRALE TASK-VERWALTUNG**

### **Problem:**
- Tasks werden aktuell in `DayPlan`-Objekten gespeichert
- Jede View lädt Tasks separat
- Keine Single Source of Truth
- Synchronisationsprobleme zwischen Views

### **Lösung:**
```
┌─────────────────────────────────────┐
│     TaskRepository (Singleton)      │
│  - Zentrale Task-Verwaltung         │
│  - Real-time Sync mit Firebase      │
│  - Caching & State Management       │
└─────────────────────────────────────┘
           │
           ├─── HeuteView
           ├─── PlanungView
           └─── NotizenView
```

**Vorteile:**
- ✅ Single Source of Truth
- ✅ Automatische Synchronisation zwischen Views
- ✅ Weniger Firebase-Queries
- ✅ Bessere Performance

---

## 🔄 **2. REAL-TIME SYNC MIT FIREBASE**

### **Aktuell:**
- Views laden Daten manuell bei `onAppear`
- Keine automatische Updates bei Änderungen
- Race Conditions möglich

### **Empfehlung:**
```swift
// TaskRepository mit Real-time Listener
class TaskRepository: ObservableObject {
    @Published var allTasks: [Task] = []
    private var listener: ListenerRegistration?
    
    func startListening() {
        listener = firebaseService.subscribeToTasks { tasks in
            self.allTasks = tasks
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
}
```

**Vorteile:**
- ✅ Automatische Updates in allen Views
- ✅ Keine manuellen Reloads nötig
- ✅ Konsistente Daten

---

## 🎨 **3. MVVM-ARCHITEKTUR**

### **Aktuell:**
- Views enthalten Business-Logic
- Direkte Firebase-Calls in Views
- Schwer testbar

### **Empfehlung:**
```
View (SwiftUI)
    ↓
ViewModel (ObservableObject)
    ↓
Repository / Service
    ↓
Firebase / Local Storage
```

**Beispiel:**
```swift
// ViewModel
class HeuteViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private let taskRepository = TaskRepository.shared
    
    func loadTasks() {
        tasks = taskRepository.getTasksForDate(Date())
    }
}

// View
struct HeuteView: View {
    @StateObject private var viewModel = HeuteViewModel()
    
    var body: some View {
        // UI only
    }
}
```

**Vorteile:**
- ✅ Trennung von UI und Business-Logic
- ✅ Testbarkeit
- ✅ Wiederverwendbarkeit

---

## 🔐 **4. FEHLERBEHANDLUNG & VALIDIERUNG**

### **Aktuell:**
- Viele `try?` ohne Fehlerbehandlung
- Keine User-Feedback bei Fehlern
- Silent Failures

### **Empfehlung:**
```swift
enum TaskError: LocalizedError {
    case invalidDate
    case invalidTime
    case networkError
    case validationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidDate: return "Ungültiges Datum"
        case .invalidTime: return "Ungültige Zeit"
        case .networkError: return "Netzwerkfehler"
        case .validationFailed(let message): return message
        }
    }
}

// Mit User-Feedback
func saveTask(_ task: Task) async {
    do {
        try await taskRepository.saveTask(task)
        showSuccess("Aufgabe gespeichert")
    } catch {
        showError(error.localizedDescription)
    }
}
```

**Vorteile:**
- ✅ Besseres User-Erlebnis
- ✅ Einfacheres Debugging
- ✅ Klare Fehlermeldungen

---

## 💾 **5. CACHING & OFFLINE-SUPPORT**

### **Empfehlung:**
```swift
class TaskRepository {
    private var cache: [String: Task] = [:]
    private var lastSync: Date?
    
    func getTask(id: String) -> Task? {
        // 1. Check Cache
        if let cached = cache[id] {
            return cached
        }
        
        // 2. Check Local Storage
        if let local = loadFromLocalStorage(id: id) {
            cache[id] = local
            return local
        }
        
        // 3. Load from Firebase (async)
        loadFromFirebase(id: id)
        return nil
    }
}
```

**Vorteile:**
- ✅ Schnellere Ladezeiten
- ✅ Offline-Funktionalität
- ✅ Weniger Netzwerk-Traffic

---

## 🧪 **6. TESTBARE ARCHITEKTUR**

### **Empfehlung:**
```swift
// Protocol für Dependency Injection
protocol TaskRepositoryProtocol {
    func saveTask(_ task: Task) async throws
    func getTasks() async throws -> [Task]
}

class TaskRepository: TaskRepositoryProtocol { ... }
class MockTaskRepository: TaskRepositoryProtocol { ... }

// ViewModel mit Dependency Injection
class HeuteViewModel: ObservableObject {
    private let repository: TaskRepositoryProtocol
    
    init(repository: TaskRepositoryProtocol = TaskRepository.shared) {
        self.repository = repository
    }
}
```

**Vorteile:**
- ✅ Unit Tests möglich
- ✅ Mock-Objekte für Tests
- ✅ Flexiblere Architektur

---

## 📊 **7. STATE MANAGEMENT**

### **Empfehlung:**
```swift
// Zentraler App State
class AppState: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedDate: Date = Date()
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    // Computed Properties
    var tasksForToday: [Task] {
        tasks.filter { $0.isForDate(Date()) }
    }
}
```

**Vorteile:**
- ✅ Konsistenter State
- ✅ Weniger Duplikation
- ✅ Einfacheres State-Management

---

## 🔄 **8. MIGRATION STRATEGY**

### **Von DayPlan zu zentraler Task-Verwaltung:**

1. **Phase 1:** Neue Tasks zentral speichern
2. **Phase 2:** Alte Tasks migrieren
3. **Phase 3:** DayPlan als View-Layer nutzen

```swift
// Migration Helper
func migrateTasksFromDayPlans() async {
    let allDayPlans = await getAllDayPlans()
    for plan in allDayPlans {
        for task in plan.tasks {
            // Save to central tasks collection
            try? await saveTask(task)
        }
    }
}
```

---

## ✅ **PRIORITÄTEN**

### **Sofort:**
1. ✅ Zentrale Task-Verwaltung
2. ✅ Real-time Sync
3. ✅ Automatische Voice Input Speicherung

### **Kurzfristig:**
4. MVVM-Architektur
5. Fehlerbehandlung verbessern
6. Caching implementieren

### **Mittelfristig:**
7. Offline-Support
8. Unit Tests
9. Performance-Optimierung

---

## 📝 **BEST PRACTICES**

1. **Single Responsibility:** Jede Klasse hat eine klare Aufgabe
2. **Dependency Injection:** Abhängigkeiten von außen übergeben
3. **Error Handling:** Immer Fehler behandeln, nie `try?` ohne Logging
4. **Logging:** Wichtige Events loggen für Debugging
5. **Validation:** Daten validieren bevor Speicherung
6. **Type Safety:** Starke Typen verwenden, keine `Any`
7. **Async/Await:** Konsistent verwenden, keine Callbacks

---

## 🚀 **NÄCHSTE SCHRITTE**

1. TaskRepository implementieren
2. Views auf Repository umstellen
3. Real-time Sync aktivieren
4. Fehlerbehandlung verbessern
5. Tests schreiben





