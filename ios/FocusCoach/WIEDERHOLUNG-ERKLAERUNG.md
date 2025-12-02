# Wiederholungsfunktionalität - Erklärung

## Wie funktioniert die Duplikat-Prüfung?

### Aktuelle Logik:

Wenn eine Task mit Wiederholung gespeichert wird, prüft das System für jeden zukünftigen Tag:

**Ein Task wird NICHT erstellt, wenn:**
- ✅ Ein Task mit **exakt gleichem Titel** existiert
- ✅ UND **exakt gleicher Zeit** (Start UND End)
- ✅ UND **kein repeatPattern** hat (also ein wiederkehrender Task ist)

### Was bedeutet das für dich?

#### ✅ **Du KANNST mehrere Tasks täglich erstellen:**

**Beispiel 1: Verschiedene Tasks mit gleicher Zeit**
```
Task 1: "Sport" um 8:00-9:00 (täglich)
Task 2: "Meditation" um 8:00-9:00 (täglich)
```
✅ **Funktioniert!** Verschiedene Titel = verschiedene Tasks

**Beispiel 2: Gleicher Task, verschiedene Zeiten**
```
Task 1: "Sport" um 8:00-9:00 (täglich)
Task 2: "Sport" um 18:00-19:00 (täglich)
```
✅ **Funktioniert!** Verschiedene Zeiten = verschiedene Tasks

**Beispiel 3: Zwei verschiedene Tasks mit täglicher Wiederholung**
```
Task 1: "Morgen Routine" um 7:00-8:00 (täglich)
Task 2: "Abend Routine" um 20:00-21:00 (täglich)
```
✅ **Funktioniert!** Verschiedene Titel UND Zeiten

#### ❌ **Du KANNST NICHT den gleichen Task doppelt erstellen:**

**Beispiel: Gleicher Task zweimal**
```
Task 1: "Sport" um 8:00-9:00 (täglich) ← Erstellt
Task 2: "Sport" um 8:00-9:00 (täglich) ← Wird NICHT erstellt (Duplikat!)
```
❌ **Wird verhindert!** Gleicher Titel + gleiche Zeit = Duplikat

### Warum diese Logik?

Die Duplikat-Prüfung verhindert:
- 🔄 Ungewollte Duplikate beim mehrmaligen Speichern
- 🔄 Mehrfache Erstellung beim täglichen Check
- 🔄 Unnötige Datenbank-Einträge

**ABER:** Sie erlaubt:
- ✅ Verschiedene Tasks mit gleicher Zeit
- ✅ Gleiche Tasks mit verschiedenen Zeiten
- ✅ Mehrere tägliche Routinen parallel

### Template-Task vs. Wiederkehrende Tasks

**Template-Task** (Original):
- Hat `repeatPattern: .daily`
- Wird einmal gespeichert
- Dient als Vorlage

**Wiederkehrende Tasks** (Automatisch erstellt):
- Haben `repeatPattern: nil`
- Werden für jeden Tag erstellt
- Sind die eigentlichen Tasks, die du siehst

### Zusammenfassung

**Du kannst:**
- ✅ Mehrere verschiedene Tasks täglich erstellen
- ✅ Gleiche Tasks zu verschiedenen Zeiten erstellen
- ✅ Verschiedene Routinen parallel haben

**Du kannst NICHT:**
- ❌ Den exakt gleichen Task (Titel + Zeit) mehrfach erstellen

Die Logik ist so designed, dass sie **Duplikate verhindert**, aber **Flexibilität erlaubt**!




