# 📝 NOTIZEN-TAB - Aufbau & Sortierung

## 🏗️ **Aufbau**

### **1. Header-Bereich**
- **Suchleiste**: Suche nach Titel oder Inhalt
- **Kategorien-Chips**: Filter nach Kategorien
  - "Alle" (Standard)
  - "Allgemein"
  - "Arbeit"
  - "Privat"
  - "Ideen"

### **2. Notizen-Liste**
- **ScrollView**: Liste aller Notizen
- **NoteRow**: Jede Notiz zeigt:
  - Titel (1 Zeile)
  - Inhalt (2 Zeilen Vorschau)
  - Checklist-Status (falls vorhanden): "2/5" (erledigt/gesamt)
- **Divider**: Trennung zwischen Notizen

### **3. Floating Action Buttons (FAB)**
- **Mikrofon-Button** (links): Spracherkennung für Notizen
- **Plus-Button** (rechts): Neue Notiz manuell erstellen

---

## 📊 **Sortierung**

### **Standard-Sortierung: Neueste zuerst**
- Sortiert nach `updatedAt` (falls vorhanden)
- Falls `updatedAt` = 0, wird `createdAt` verwendet
- **Neueste Notizen erscheinen oben**

### **Beispiel:**
```
1. Notiz (updatedAt: 2024-11-30 10:00) ← Neueste
2. Notiz (updatedAt: 2024-11-29 15:00)
3. Notiz (createdAt: 2024-11-28 09:00) ← Älteste
```

---

## 🔍 **Filterung**

### **1. Text-Suche**
- Durchsucht **Titel** und **Inhalt**
- Case-insensitive (Groß-/Kleinschreibung egal)
- Live-Filterung während der Eingabe

### **2. Kategorie-Filter**
- Filtert nach ausgewählter Kategorie
- "Alle" zeigt alle Notizen

### **3. Kombiniert**
- Suche + Kategorie können kombiniert werden
- Beispiel: "Arbeit" + "Meeting" → Zeigt nur Arbeit-Notizen mit "Meeting"

---

## 📱 **Notiz-Struktur**

```swift
struct Note {
    id: String                    // Eindeutige ID
    title: String                 // Titel der Notiz
    content: String               // Inhalt/Text
    category: NoteCategory?       // Optional: Kategorie
    checklist: [ChecklistItem]?   // Optional: Checkliste
    createdAt: Int64              // Erstellungszeit (Timestamp)
    updatedAt: Int64              // Letzte Änderung (Timestamp)
}
```

### **Kategorien:**
- `allgemein` → "Allgemein"
- `arbeit` → "Arbeit"
- `privat` → "Privat"
- `ideen` → "Ideen"

### **ChecklistItem:**
```swift
struct ChecklistItem {
    id: String
    text: String
    completed: Bool
}
```

---

## 🎤 **Spracherkennung für Notizen**

### **Funktionsweise:**
1. **Mikrofon-Button** drücken
2. **SimpleVoiceInputView** öffnet sich
3. **Sprechen** → Transkription erscheint live
4. **"Stoppen & Speichern"** → Notiz wird erstellt
   - **Titel**: Erste Zeile bis zum ersten Punkt
   - **Inhalt**: Kompletter transkribierter Text

### **Unterschied zu Task-Spracherkennung:**
- **Notizen**: Nur Transkription, kein Parsing
- **Tasks**: Transkription + Parsing (Datum, Zeit, etc.)

---

## 💾 **Speicherung**

### **Aktuell:**
- Notizen werden lokal in `notes` Array gespeichert
- `loadNotes()` und `saveNotes()` sind noch TODO

### **Geplant:**
- Firebase Integration (wie Tasks)
- Real-time Sync zwischen Geräten
- Cloud-Backup

---

## 🎨 **UI-Komponenten**

### **CategoryChip**
- Kategorie-Button mit Auswahl-Status
- Blau wenn ausgewählt, grau wenn nicht

### **NoteRow**
- Zeigt Notiz-Vorschau
- NavigationLink zu `NoteDetailView`

### **NoteDetailView**
- Vollständige Notiz-Ansicht
- Editierbarer Titel und Inhalt
- Checkliste (falls vorhanden)

### **NewNoteSheet**
- Formular für neue Notiz
- Titel + Inhalt
- Optional: Kategorie-Auswahl

---

## 🔄 **Workflow**

### **Notiz erstellen:**
1. **Mikrofon** → Sprechen → Automatisch gespeichert
2. **Plus** → Manuell eingeben → Speichern

### **Notiz bearbeiten:**
1. Auf Notiz tippen → `NoteDetailView` öffnet sich
2. Titel/Inhalt ändern
3. Automatisch gespeichert (bei Firebase-Integration)

### **Notiz suchen:**
1. Suchleiste nutzen
2. Optional: Kategorie filtern
3. Live-Filterung

---

## 📈 **Zukünftige Verbesserungen**

- [ ] Firebase Integration
- [ ] Rich Text Formatting
- [ ] Bilder in Notizen
- [ ] Tags statt nur Kategorien
- [ ] Archivierung
- [ ] Export (PDF, Text)
- [ ] Teilen-Funktion




