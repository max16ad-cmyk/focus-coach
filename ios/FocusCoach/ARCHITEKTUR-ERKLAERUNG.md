# Architektur-Erklärung: Aufgaben, Routinen & Wiederholungen

## 📋 Übersicht

Diese Dokumentation erklärt:
1. Wie die Aufgaben-Synchronisation funktioniert
2. Wie wiederkehrende Tasks erstellt werden
3. Wie Routinen funktionieren
4. Warum bestimmte Probleme auftreten können

---

## 🔄 Aufgaben-Synchronisation (TaskRepository)

### Problem (vorher):
- Aufgaben wurden in verschiedenen Views unterschiedlich gespeichert
- Keine zentrale Quelle der Wahrheit
- Tasks wurden nicht synchron zwischen `HeuteView` und `PlanungView` angezeigt

### Lösung (jetzt):
**TaskRepository** als zentrale Verwaltung:

```swift
TaskRepository.shared
├── allTasks: [Task]          // Alle Tasks (Real-time Sync)
├── startListening()           // Startet Firebase Listener
├── saveTask()                 // Speichert Task + erstellt wiederkehrende Tasks
├── updateTask()               // Aktualisiert Task
└── deleteTask()               // Löscht Task
```

### Wie es funktioniert:

1. **Real-time Sync:**
   - `TaskRepository` hört auf Firebase `tasks` Collection
   - Bei jeder Änderung wird `allTasks` automatisch aktualisiert
   - Alle Views beobachten `TaskRepository.shared.allTasks`

2. **Single Source of Truth:**
   - Alle Tasks werden über `TaskRepository` gespeichert
   - Keine lokalen Kopien mehr
   - Konsistenz garantiert

3. **Integration:**
   ```swift
   // In HeuteView, PlanungView, etc.
   @StateObject private var taskRepository = TaskRepository.shared
   
   // Tasks für heute
   private var todayTasks: [Task] {
       taskRepository.getTasksForToday()
   }
   ```

---

## 🔁 Wiederkehrende Tasks (TaskRepeater)

### Problem:
Wiederkehrende Tasks werden nicht erstellt, obwohl `repeatPattern` gesetzt ist.

### Wie es funktionieren sollte:

1. **Task mit Wiederholung speichern:**
   ```swift
   let task = Task(
       title: "Arbeit",
       repeatPattern: .daily,
       scheduledStartTime: "08:00",
       scheduledEndTime: "17:00"
   )
   await taskRepository.saveTask(task)
   ```

2. **Automatische Erstellung:**
   - `TaskRepository.saveTask()` erkennt `repeatPattern`
   - Ruft `TaskRepeater.createRepeatingTasks()` auf
   - Erstellt Tasks für die nächsten 30 Tage

3. **Template-Task vs. Wiederkehrende Tasks:**
   - **Template-Task:** Hat `repeatPattern: .daily` (Original)
   - **Wiederkehrende Tasks:** Haben `repeatPattern: nil` (Automatisch erstellt)

### Debugging:

**Warum funktioniert es nicht?**

1. **Prüfe ob `repeatPattern` gesetzt ist:**
   ```swift
   print("Task repeatPattern: \(task.repeatPattern)")
   ```

2. **Prüfe ob TaskRepeater aufgerufen wird:**
   - In `TaskRepository.saveTask()` sollte `TaskRepeater.shared.createRepeatingTasks()` aufgerufen werden
   - Logs: `"🔄 TaskRepeater: Erstelle wiederkehrende Tasks..."`

3. **Prüfe Duplikat-Schutz:**
   - Tasks werden nicht erstellt, wenn bereits ein Task mit gleichem Titel + Zeit existiert
   - Logs: `"✅ TaskRepeater: Task erstellt für..."`

### Fixes implementiert:

1. ✅ **Direkter FirebaseService-Zugriff:** TaskRepeater speichert direkt über `firebaseService.saveTask()` (verhindert Endlosschleife)
2. ✅ **Besseres Logging:** Ausführliche Logs für Debugging
3. ✅ **Duplikat-Prüfung:** Verhindert mehrfache Erstellung

---

## 📅 Routinen (RoutineRepository)

### Problem:
Routinen werden nicht angezeigt und erstellen keine Tasks.

### Lösung:

**RoutineRepository** als zentrale Verwaltung:

```swift
RoutineRepository.shared
├── allRoutines: [Routine]     // Alle Routinen (Real-time Sync)
├── saveRoutine()             // Speichert Routine + erstellt Tasks
├── updateRoutine()            // Aktualisiert Routine
└── deleteRoutine()            // Löscht Routine
```

### Wie Routinen funktionieren:

1. **Routine erstellen:**
   ```swift
   let routine = Routine(
       name: "Morgen Routine",
       tasks: [
           RoutineTask(title: "Aufstehen", startTime: "07:00", endTime: "07:30"),
           RoutineTask(title: "Meditation", startTime: "07:30", endTime: "08:00")
       ],
       repeatPattern: .daily,
       isActive: true
   )
   await routineRepository.saveRoutine(routine)
   ```

2. **Automatische Task-Erstellung:**
   - `RoutineRepository.saveRoutine()` erstellt automatisch Tasks aus der Routine
   - Für jeden `RoutineTask` wird ein `Task` mit `repeatPattern` erstellt
   - `TaskRepeater` erstellt dann wiederkehrende Tasks

3. **Firebase Storage:**
   - Routinen werden in `users/{userId}/routines/{routineId}` gespeichert
   - Real-time Sync über `subscribeToRoutines()`

### Workflow:

```
Routine erstellen
    ↓
RoutineRepository.saveRoutine()
    ↓
createTasksFromRoutine() → Erstellt Tasks mit repeatPattern
    ↓
TaskRepeater.createRepeatingTasks() → Erstellt Tasks für nächste 30 Tage
    ↓
Tasks werden in Firebase gespeichert
    ↓
TaskRepository synchronisiert automatisch
    ↓
Tasks erscheinen in HeuteView/PlanungView
```

---

## 📆 Monatswechsel beim Scrollen

### Problem:
Monat wechselt nicht automatisch beim Scrollen, nur beim Anklicken.

### Lösung:

In `ScrollableDayBar`:
- `onChange(of: selectedDate)` ruft `updateCurrentMonthIfNeeded()` auf
- Beim Swipen wird `selectedDate` aktualisiert
- Monat wird automatisch aktualisiert wenn Datum in anderem Monat liegt

### Fix:
```swift
.onChange(of: selectedDate) { newDate in
    loadMoreDaysIfNeeded(around: newDate)
    updateCurrentMonthIfNeeded(for: newDate)  // ← NEU
    proxy.scrollTo(newDate, anchor: UnitPoint.center)
}
```

---

## 🏗️ Architektur-Übersicht

### Datenfluss:

```
Firebase Firestore
    ↓
FirebaseService (saveTask, subscribeToTasks)
    ↓
TaskRepository (Single Source of Truth)
    ↓
Views (HeuteView, PlanungView, AufgabenView)
```

### Services:

1. **FirebaseService:**
   - Direkte Firebase-Interaktionen
   - CRUD-Operationen für Tasks, Routinen, Settings

2. **TaskRepository:**
   - Zentrale Task-Verwaltung
   - Real-time Synchronisation
   - Trigger für TaskRepeater

3. **RoutineRepository:**
   - Zentrale Routine-Verwaltung
   - Erstellt Tasks aus Routinen
   - Real-time Synchronisation

4. **TaskRepeater:**
   - Erstellt wiederkehrende Tasks
   - Wird von TaskRepository und RoutineRepository aufgerufen

### Warum diese Architektur?

1. **Single Source of Truth:**
   - Alle Daten kommen aus einem Repository
   - Keine Inkonsistenzen zwischen Views

2. **Real-time Sync:**
   - Änderungen werden sofort synchronisiert
   - Multi-Device Support

3. **Separation of Concerns:**
   - FirebaseService: Datenbank-Zugriff
   - Repository: Business Logic
   - Views: UI

---

## 🐛 Bekannte Probleme & Lösungen

### Problem 1: Wiederkehrende Tasks werden nicht erstellt

**Ursache:**
- TaskRepeater wird nicht aufgerufen
- Duplikat-Schutz verhindert Erstellung
- `repeatPattern` ist nicht gesetzt

**Lösung:**
- Prüfe Logs: `"🔄 TaskRepeater: Erstelle wiederkehrende Tasks..."`
- Prüfe ob Template-Task `repeatPattern` hat
- Prüfe ob bereits Tasks existieren (Duplikat-Schutz)

### Problem 2: Routinen werden nicht angezeigt

**Ursache:**
- Routinen werden nur lokal gespeichert (nicht in Firebase)
- RoutineRepository hört nicht auf Firebase

**Lösung:**
- ✅ Routinen werden jetzt in Firebase gespeichert
- ✅ RoutineRepository synchronisiert automatisch

### Problem 3: Monat wechselt nicht beim Scrollen

**Ursache:**
- `updateCurrentMonthIfNeeded()` wird nicht aufgerufen

**Lösung:**
- ✅ Wird jetzt in `onChange(of: selectedDate)` aufgerufen

---

## 📝 Zusammenfassung

### Was wurde verbessert:

1. ✅ **TaskRepository:** Zentrale Task-Verwaltung mit Real-time Sync
2. ✅ **TaskRepeater:** Automatische Erstellung wiederkehrender Tasks
3. ✅ **RoutineRepository:** Zentrale Routine-Verwaltung mit Firebase-Sync
4. ✅ **Monatswechsel:** Automatisch beim Scrollen
5. ✅ **Besseres Logging:** Für Debugging

### Nächste Schritte:

1. Teste wiederkehrende Tasks: Erstelle Task mit `repeatPattern: .daily`
2. Teste Routinen: Erstelle Routine und prüfe ob Tasks erstellt werden
3. Prüfe Logs: Schaue in Console nach `TaskRepeater` und `RoutineRepository` Logs

---

## 🔍 Debugging-Tipps

### Logs prüfen:

```swift
// TaskRepository
"✅ TaskRepository: Task saved: ..."
"✅ TaskRepository: Wiederkehrende Tasks erstellt für '...'"

// TaskRepeater
"🔄 TaskRepeater: Erstelle wiederkehrende Tasks für '...'"
"✅ TaskRepeater: Task erstellt für ...: '...'"

// RoutineRepository
"✅ RoutineRepository: Routine saved: ..."
"🔄 RoutineRepository: Erstelle Tasks aus Routine '...'"
```

### Firebase prüfen:

1. Öffne Firebase Console
2. Gehe zu `users/{userId}/tasks`
3. Prüfe ob Tasks mit `repeatPattern` existieren
4. Prüfe ob wiederkehrende Tasks erstellt wurden

---

## 💡 Best Practices

1. **Immer über Repository speichern:**
   ```swift
   // ✅ RICHTIG
   await taskRepository.saveTask(task)
   
   // ❌ FALSCH
   await firebaseService.saveTask(task)  // Bypass Repository
   ```

2. **Routinen aktivieren:**
   ```swift
   routine.isActive = true  // Nur aktive Routinen erstellen Tasks
   ```

3. **Wiederholungsmuster setzen:**
   ```swift
   task.repeatPattern = .daily  // Muss gesetzt sein!
   ```




