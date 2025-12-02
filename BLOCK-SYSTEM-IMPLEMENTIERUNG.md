# Block-System Implementierung - Phase 1

## ✅ Was wurde bereits implementiert:

### 1. **Task Model erweitert**
- ✅ `parentTaskId: String?` - Für verschachtelte Tasks
- ✅ `subTaskIds: [String]?` - Liste der Sub-Task IDs
- ✅ `order: Int?` - Reihenfolge innerhalb der Liste
- ✅ Helper Properties: `isParentTask`, `isSubTask`, `hasSubTasks`

### 2. **TaskBlock Component erstellt**
- ✅ Block-basierte Darstellung von Tasks
- ✅ Verschachtelung für Sub-Tasks (mit Indentation)
- ✅ Expand/Collapse für Sub-Tasks
- ✅ Drag Handle für Top-Level Tasks
- ✅ Visuelle Hierarchie durch Indentation

### 3. **BreadcrumbView Component erstellt**
- ✅ Breadcrumb-Navigation wie Craft
- ✅ Klickbare Navigation zwischen Ebenen
- ✅ Visuelle Hierarchie-Anzeige

---

## 🔄 Was als NÄCHSTES zu tun ist:

### **Schritt 1: PlannedTaskRow finden und analysieren**
- Finde die aktuelle `PlannedTaskRow` Implementierung
- Verstehe wie Tasks aktuell angezeigt werden
- Plane Migration zu TaskBlock

### **Schritt 2: TaskRepository erweitern**
- Methoden für Hierarchie-Management:
  - `addSubTask(to parentId: String, task: Task)`
  - `removeSubTask(from parentId: String, taskId: String)`
  - `moveTask(taskId: String, newParentId: String?, newOrder: Int)`
  - `getSubTasks(for taskId: String) -> [Task]`

### **Schritt 3: Drag & Drop vollständig implementieren**
- Drop-Zones für Tasks
- Visual Feedback beim Dragging
- Reorder-Logik
- Parent-Child-Beziehungen beim Drop

### **Schritt 4: HeuteView auf Block-System umstellen**
- Ersetze `PlannedTaskRow` mit `TaskBlock`
- Implementiere Breadcrumb-Navigation
- Filtere Top-Level Tasks (ohne parentTaskId)

### **Schritt 5: Task-Detail-View erweitern**
- Sub-Tasks hinzufügen/bearbeiten
- Hierarchie-Anzeige
- Backlinks zu Parent-Tasks

---

## 📋 Nächste Schritte im Detail:

### **1. TaskRepository erweitern** (Priorität: HOCH)
```swift
// Neue Methoden in TaskRepository:
func addSubTask(to parentId: String, task: Task) async throws
func removeSubTask(from parentId: String, taskId: String) async throws
func moveTask(taskId: String, newParentId: String?, newOrder: Int) async throws
func getSubTasks(for taskId: String) -> [Task]
func getTopLevelTasks(for date: Date) -> [Task] // Nur Tasks ohne parentTaskId
```

### **2. Drag & Drop implementieren** (Priorität: HOCH)
- `DragGesture` für TaskBlock
- Drop-Zones erkennen
- Visual Feedback
- Reorder-Logik

### **3. HeuteView Integration** (Priorität: MITTEL)
- Filtere Top-Level Tasks
- Verwende TaskBlock statt PlannedTaskRow
- Breadcrumb-Navigation hinzufügen

### **4. Task-Detail-View** (Priorität: MITTEL)
- Sub-Tasks Liste anzeigen
- Sub-Task hinzufügen Button
- Hierarchie-Navigation

---

## 🎯 Empfohlene Reihenfolge:

1. **TaskRepository erweitern** → Grundlage für Hierarchie
2. **Drag & Drop implementieren** → Kern-Feature des Block-Systems
3. **HeuteView Integration** → Sichtbare Verbesserung
4. **Task-Detail-View** → Vollständige Hierarchie-Unterstützung

---

## 💡 Wichtige Überlegungen:

- **Backward Compatibility:** Bestehende Tasks ohne `parentTaskId` müssen weiterhin funktionieren
- **Performance:** Bei vielen verschachtelten Tasks könnte Rendering langsam werden → Lazy Loading
- **Firebase Sync:** Hierarchie-Änderungen müssen synchronisiert werden
- **UI/UX:** Verschachtelung sollte nicht zu tief sein (max. 3-4 Ebenen)




