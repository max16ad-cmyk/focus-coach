# 🏗️ FOCUS COACH - App Architektur

## 📋 **Übersicht**

Die App folgt einem **MVVM-ähnlichen Pattern** mit zentraler Datenverwaltung:

```
Views (UI)
    ↓
ViewModels (Logic) ← NEU!
    ↓
Repositories (Data Management)
    ↓
Services (Firebase, Gemini, etc.)
    ↓
Models (Data Structures)
```

---

## 🗂️ **Verzeichnis-Struktur**

```
FocusCoach/
├── Models/              # Datenstrukturen
│   ├── Task.swift
│   ├── Note.swift
│   ├── User.swift
│   └── ...
├── Views/              # UI-Komponenten
│   ├── HeuteView.swift
│   ├── PlanungView.swift
│   ├── NotizenView.swift
│   └── ...
├── ViewModels/         # Business Logic ← NEU!
│   └── VoiceInputViewModel.swift
├── Services/           # Externe Services
│   ├── FirebaseService.swift
│   ├── TaskRepository.swift  ← Zentrale Datenverwaltung
│   ├── GeminiService.swift
│   └── ...
└── Utils/              # Utilities
    ├── Logger.swift
    └── Theme.swift
```

---

## 🎯 **Zentrale Datenverwaltung: TaskRepository**

### **Single Source of Truth**

**TaskRepository** ist die **einzige Quelle** für alle Tasks:

```swift
@MainActor
class TaskRepository: ObservableObject {
    @Published var allTasks: [Task] = []  // Alle Tasks
    
    // Query-Methoden:
    func getTasksForToday() -> [Task]
    func getTasksForDate(_ date: Date) -> [Task]
    func getTasksForWeek(containing date: Date) -> [Task]
    
    // CRUD-Operationen:
    func saveTask(_ task: Task) async throws
    func updateTask(_ task: Task) async throws
    func deleteTask(_ taskId: String) async throws
    func toggleTaskCompletion(_ task: Task) async throws
}
```

### **Wie Views darauf zugreifen:**

#### **HeuteView (Today's Tasks):**
```swift
@StateObject private var taskRepository = TaskRepository.shared

private var todayTasks: [Task] {
    taskRepository.getTasksForToday()  // Filtert automatisch
}
```

#### **PlanungView (Weekly Planning):**
```swift
@StateObject private var taskRepository = TaskRepository.shared

private var weekTasks: [Task] {
    taskRepository.getTasksForWeek(containing: selectedDate)
}
```

### **Vorteile:**
- ✅ **Einheitliche Datenquelle** → Keine Duplikate
- ✅ **Real-time Sync** → Automatische Updates
- ✅ **Einfache Queries** → `getTasksForToday()`, etc.
- ✅ **Konsistenz** → Alle Views sehen gleiche Daten

---

## 🔄 **Datenfluss**

### **Task erstellen:**

```
1. User erstellt Task (z.B. via VoiceInputView)
    ↓
2. VoiceInputView → TaskRepository.saveTask()
    ↓
3. TaskRepository → FirebaseService.saveTask()
    ↓
4. Firebase speichert Task
    ↓
5. Firebase Listener → TaskRepository.allTasks wird aktualisiert
    ↓
6. @Published allTasks → Alle Views werden automatisch aktualisiert
    ↓
7. HeuteView & PlanungView zeigen neue Task
```

### **Task aktualisieren:**

```
1. User markiert Task als erledigt
    ↓
2. HeuteView → TaskRepository.toggleTaskCompletion()
    ↓
3. TaskRepository → FirebaseService.updateTask()
    ↓
4. Firebase aktualisiert Task
    ↓
5. Firebase Listener → TaskRepository.allTasks wird aktualisiert
    ↓
6. Alle Views zeigen aktualisierte Task
```

---

## 🎤 **Voice Input Architektur (Verbessert)**

### **Vorher (Problem):**
- Logik direkt in `VoiceInputView`
- Schwer testbar
- Keine Validierung
- Kein Confidence-Score

### **Jetzt (Verbessert):**

```
VoiceInputView (UI only)
    ↓
VoiceInputViewModel (Logic)
    ├── Live-Parsing
    ├── Validierung
    ├── Confidence-Score
    └── Error-Handling
    ↓
GeminiService (Parsing)
    ├── Fallback-Parser
    └── Gemini API
    ↓
VoiceTaskResultValidator (Validation)
    ├── Date-Format Check
    ├── Time-Format Check
    └── Title Validation
```

### **Vorteile:**
- ✅ **Separation of Concerns** → UI ≠ Logic
- ✅ **Testbar** → ViewModel kann gemockt werden
- ✅ **Validierung** → Fehler werden früh erkannt
- ✅ **Confidence-Score** → User sieht Zuverlässigkeit

---

## 📊 **Ähnliche Verbesserungen möglich**

### **1. NotizenView**
**Aktuell:**
- Logik direkt in View
- Keine zentrale Verwaltung

**Verbesserung:**
```swift
// NotesRepository (wie TaskRepository)
@MainActor
class NotesRepository: ObservableObject {
    @Published var allNotes: [Note] = []
    
    func getNotesForCategory(_ category: NoteCategory?) -> [Note]
    func saveNote(_ note: Note) async throws
    // ...
}

// NotesViewModel
class NotesViewModel: ObservableObject {
    @Published var filteredNotes: [Note] = []
    @Published var searchText: String = ""
    // ...
}
```

### **2. Settings**
**Aktuell:**
- Settings direkt in View

**Verbesserung:**
```swift
// SettingsViewModel
class SettingsViewModel: ObservableObject {
    @Published var settings: UserSettings
    func updateSettings(_ newSettings: UserSettings) async throws
    // ...
}
```

### **3. BlockingService**
**Aktuell:**
- Service direkt verwendet

**Verbesserung:**
```swift
// BlockingViewModel
class BlockingViewModel: ObservableObject {
    @Published var blockedApps: [ApplicationToken] = []
    func toggleBlocking(for app: ApplicationToken) async throws
    // ...
}
```

---

## 🔧 **Struktur-Verbesserungen**

### **1. Klarere Trennung**

**Vorher:**
```
Views/
  ├── VoiceInputView.swift (UI + Logic)
  └── HeuteView.swift (UI + Logic)
```

**Nachher:**
```
Views/
  ├── VoiceInputView.swift (nur UI)
  └── HeuteView.swift (nur UI)
ViewModels/
  ├── VoiceInputViewModel.swift (Logic)
  └── TodayViewModel.swift (Logic)
```

### **2. Repository-Pattern konsistent**

**Alle Daten sollten über Repositories:**
- ✅ Tasks → `TaskRepository`
- ⚠️ Notes → `NotesRepository` (noch zu erstellen)
- ⚠️ Settings → `SettingsRepository` (noch zu erstellen)

### **3. ViewModels für komplexe Views**

**Views mit viel Logic sollten ViewModels haben:**
- ✅ `VoiceInputView` → `VoiceInputViewModel` (fertig)
- ⚠️ `HeuteView` → `TodayViewModel` (könnte helfen)
- ⚠️ `PlanungView` → `PlanningViewModel` (könnte helfen)

---

## 🚀 **Migration-Strategie**

### **Phase 1: Voice Input (Fertig)**
- ✅ ViewModel erstellt
- ✅ Validierung hinzugefügt
- ✅ Logging verbessert
- ✅ Confidence-Score implementiert

### **Phase 2: Notes (Nächster Schritt)**
1. `NotesRepository` erstellen
2. `NotesViewModel` erstellen
3. `NotizenView` refactoren

### **Phase 3: Andere Views**
1. ViewModels für komplexe Views
2. Repositories für alle Datenquellen
3. Konsistente Architektur

---

## 📈 **Vorteile der neuen Architektur**

### **Testbarkeit:**
- ViewModels können isoliert getestet werden
- Repositories können gemockt werden
- UI-Tests werden einfacher

### **Wartbarkeit:**
- Klare Trennung von Concerns
- Einfacher zu erweitern
- Weniger Code-Duplikation

### **Performance:**
- ViewModels können optimiert werden
- Caching auf Repository-Ebene
- Bessere State-Management

### **User Experience:**
- Schnellere Updates (0.8s statt 1.5s)
- Confidence-Score zeigt Zuverlässigkeit
- Direkte Bestätigung möglich

---

## 🎯 **Nächste Schritte**

1. ✅ Voice Input ViewModel (fertig)
2. ⏭️ Notes Repository & ViewModel
3. ⏭️ Settings Repository & ViewModel
4. ⏭️ Weitere ViewModels für komplexe Views
5. ⏭️ Unit-Tests für ViewModels
6. ⏭️ Integration-Tests für Repositories



