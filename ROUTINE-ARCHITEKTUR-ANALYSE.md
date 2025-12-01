# Routine-Architektur: Speicher- und Filter-Prinzip

## 📋 Aktuelle Architektur

### 1. **Routine-Speicherung (Firebase)**

```
EditRoutineSheet (UI)
    ↓
RoutineRepository.updateRoutine()
    ↓
1. deleteTasksForRoutine() → Löscht ALLE Tasks mit routineId
2. Warte 0.5 Sekunden
3. FirebaseService.saveRoutine() → Speichert Routine mit repeatWeekdays
4. createTasksFromRoutine() → Erstellt neue Template-Tasks
```

**Wichtig:**
- `repeatWeekdays` wird als JSON in Firebase gespeichert: `{"monday":false, "tuesday":true, ...}`
- Beim Laden wird es korrekt dekodiert
- `merge: false` stellt sicher, dass `nil`-Werte auch gespeichert werden

### 2. **Task-Erstellung aus Routinen**

```
RoutineRepository.createTasksFromRoutine()
    ↓
Für jeden RoutineTask:
    1. Erstelle Template-Task mit:
       - repeatPattern: routine.repeatPattern
       - repeatWeekdays: routine.repeatWeekdays
       - routineId: routine.id
    2. Speichere Template-Task
    3. TaskRepeater.createRepeatingTasks() (im Hintergrund)
       → Erstellt einzelne Tasks für die nächsten 30 Tage
```

**Wichtig:**
- Template-Tasks haben `repeatPattern` und `repeatWeekdays`
- Wiederkehrende Instanzen haben `repeatPattern: nil`, aber behalten `routineId`

### 3. **TaskRepeater: Wiederkehrende Tasks**

```
TaskRepeater.createRepeatingTasks(from: templateTask)
    ↓
1. Berechne Daten basierend auf repeatPattern:
   - daily → jeden Tag
   - weekly → jeden Wochentag (basierend auf repeatWeekdays)
   - weekdays → nur ausgewählte Wochentage
   - monthly → jeden Monat
    ↓
2. Für jeden berechneten Tag:
   - Prüfe ob Task bereits existiert (Titel + Zeit)
   - Erstelle neuen Task mit:
     - scheduledDate: "YYYY-MM-DD"
     - repeatPattern: nil (nur Template hat Pattern)
     - routineId: templateTask.routineId (BEIBEHALTEN!)
```

**Wichtig:**
- `routineId` wird bei allen wiederkehrenden Tasks beibehalten
- Duplikat-Schutz verhindert doppelte Tasks

### 4. **Task-Löschung bei Routine-Update**

```
RoutineRepository.updateRoutine()
    ↓
deleteTasksForRoutine(routineId)
    ↓
1. Filtere alle Tasks mit routineId
2. Lösche sequenziell (nicht parallel)
3. Warte 0.5 Sekunden
4. Erstelle neue Tasks
```

**Wichtig:**
- Alle Tasks (Template + Instanzen) werden gelöscht
- Sequenzielle Löschung verhindert Race Conditions

## 🔍 Aktuelle Probleme & Lösungen

### ✅ **Gelöst:**
1. **Wochentage werden korrekt gespeichert** → Explizite Kopie von `repeatWeekdays`
2. **Tasks werden korrekt gelöscht** → `routineId` wird bei allen Tasks beibehalten
3. **Firebase-Synchronisation** → `merge: false` stellt sicher, dass `nil`-Werte gespeichert werden

### ⚠️ **Potenzielle Probleme:**

#### 1. **Race Conditions bei Task-Erstellung**
- **Problem:** `TaskRepeater` läuft im Hintergrund, während `deleteTasksForRoutine` noch läuft
- **Aktuell:** 0.5 Sekunden Wartezeit hilft, aber ist nicht 100% sicher
- **Verbesserung:** Warte auf Abschluss aller Löschungen vor Task-Erstellung

#### 2. **Duplikat-Schutz ist nicht perfekt**
- **Problem:** Prüft nur Titel + Zeit, nicht `routineId`
- **Aktuell:** Funktioniert, aber könnte bei mehreren Routinen mit gleichen Tasks problematisch sein
- **Verbesserung:** Auch `routineId` in Duplikat-Prüfung einbeziehen

#### 3. **Template-Tasks werden nicht gelöscht**
- **Problem:** Template-Tasks (mit `repeatPattern`) bleiben nach Löschung bestehen
- **Aktuell:** Werden nicht gelöscht, da sie keine `scheduledDate` haben
- **Verbesserung:** Template-Tasks explizit identifizieren und löschen

#### 4. **Performance bei vielen Tasks**
- **Problem:** Sequenzielle Löschung von 30+ Tasks kann langsam sein
- **Aktuell:** Funktioniert, aber könnte bei 100+ Tasks problematisch sein
- **Verbesserung:** Batch-Löschung oder parallele Löschung mit Rate-Limiting

## 💡 Verbesserungsvorschläge

### **Option 1: Minimal (Empfohlen)**
Nur kritische Verbesserungen:

1. **Template-Tasks explizit löschen:**
   ```swift
   // In deleteTasksForRoutine:
   let templateTasks = tasksToDelete.filter { $0.repeatPattern != nil }
   let instanceTasks = tasksToDelete.filter { $0.repeatPattern == nil }
   // Lösche beide separat
   ```

2. **Warte auf Abschluss aller Löschungen:**
   ```swift
   // In updateRoutine:
   await deleteTasksForRoutine(routineId: routine.id)
   // Warte bis alle Tasks wirklich gelöscht sind
   while taskRepository.allTasks.contains(where: { $0.routineId == routine.id }) {
       try await Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunden
   }
   ```

**Vorteil:** Einfach, sicher, keine großen Architektur-Änderungen

### **Option 2: Mittel (Wenn nötig)**
Zusätzliche Verbesserungen:

1. **Duplikat-Schutz verbessern:**
   ```swift
   // In TaskRepeater:
   let alreadyExists = existingTasks.contains { existingTask in
       sameTitle && sameTime && 
       existingTask.routineId == templateTask.routineId // Auch routineId prüfen
   }
   ```

2. **Batch-Löschung:**
   ```swift
   // In deleteTasksForRoutine:
   // Lösche in Batches von 10 Tasks
   for batch in tasksToDelete.chunked(into: 10) {
       await withTaskGroup(of: Void.self) { group in
           for task in batch {
               group.addTask {
                   try? await taskRepository.deleteTask(task.id)
               }
           }
       }
   }
   ```

**Vorteil:** Bessere Performance, robusterer Duplikat-Schutz

### **Option 3: Maximal (Nur wenn wirklich nötig)**
Große Architektur-Änderungen:

1. **Separate Collection für Template-Tasks**
2. **Transaction-basierte Updates**
3. **Caching-Layer für Tasks**

**Nachteil:** Viel komplexer, möglicherweise Overkill

## 🎯 Empfehlung

**Aktuell funktioniert das System gut!** Die Logs zeigen:
- ✅ Wochentage werden korrekt gespeichert
- ✅ Tasks werden korrekt gelöscht (30 Tasks gefunden und gelöscht)
- ✅ Neue Tasks werden mit richtiger `routineId` erstellt

**Empfehlung: Option 1 (Minimal)**
- Nur Template-Tasks explizit löschen
- Warte auf Abschluss aller Löschungen

**Warum nicht mehr?**
- Das System funktioniert bereits gut
- Mehr Komplexität = mehr Fehlerquellen
- Performance ist aktuell ausreichend (30 Tasks in <1 Sekunde)

## 📊 Datenfluss-Diagramm

```
┌─────────────────┐
│ EditRoutineSheet│
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│ RoutineRepository   │
│ .updateRoutine()    │
└────────┬────────────┘
         │
         ├─► deleteTasksForRoutine()
         │   └─► Filtere Tasks mit routineId
         │       └─► Lösche sequenziell
         │
         ├─► Warte 0.5 Sekunden
         │
         ├─► FirebaseService.saveRoutine()
         │   └─► Speichere Routine mit repeatWeekdays
         │
         └─► createTasksFromRoutine()
             └─► Erstelle Template-Tasks
                 └─► TaskRepeater.createRepeatingTasks()
                     └─► Erstelle Instanzen für 30 Tage
```

## 🔧 Code-Stellen für Verbesserungen

1. **`RoutineRepository.deleteTasksForRoutine()`** → Template-Tasks explizit löschen
2. **`RoutineRepository.updateRoutine()`** → Warte auf Abschluss aller Löschungen
3. **`TaskRepeater.createRepeatingTasks()`** → Duplikat-Schutz mit `routineId`



