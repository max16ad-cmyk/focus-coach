# Kalender-Architektur Erklärung

## Aktuelle Struktur

### 1. **HeuteView** (Haupt-View)
```swift
@State private var selectedDate: Date = Date()      // Aktuell ausgewähltes Datum
@State private var currentMonth: Date = Date()      // Aktueller Monat für Navigation
@State private var showCalendar = false              // Kalender ausgeklappt?

private var monthYearString: String {
    // Computed Property - wird bei jedem Render neu berechnet
    return formatter.string(from: selectedDate)     // ❌ PROBLEM!
}
```

### 2. **ScrollableDayBar** (Scrollbare Tag-Leiste)
```swift
@Binding var selectedDate: Date      // Binding zu HeuteView.selectedDate
@Binding var currentMonth: Date      // Binding zu HeuteView.currentMonth

// Beim Swipen:
selectedDate = newDate               // ✅ Aktualisiert Binding
updateCurrentMonthIfNeeded(for: newDate)  // ✅ Aktualisiert currentMonth
```

## Das Problem

### Warum `monthYearString` nicht aktualisiert wird:

1. **Computed Property Problem:**
   - `monthYearString` ist eine computed property
   - Sie wird bei jedem Render neu berechnet
   - ABER: SwiftUI rendert nur neu, wenn sich `@State` Variablen ändern
   - `selectedDate` ändert sich zwar, aber SwiftUI erkennt nicht immer, dass `monthYearString` sich geändert hat

2. **DateFormatter Problem:**
   - `DateFormatter` wird jedes Mal neu erstellt
   - SwiftUI vergleicht möglicherweise die Referenz, nicht den Wert
   - → View wird nicht neu gerendert

3. **Binding Update Problem:**
   - Wenn `selectedDate` in `ScrollableDayBar` geändert wird
   - Wird das Binding aktualisiert
   - ABER: Die View-Hierarchie rendert möglicherweise nicht sofort neu

## Die Lösung

### Option 1: @Published Property (BESTE LÖSUNG)
```swift
@State private var displayedMonthYear: String = ""

private func updateMonthYear(from date: Date) {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    formatter.locale = Locale(identifier: "de_DE")
    displayedMonthYear = formatter.string(from: date)
}

.onChange(of: selectedDate) { newDate in
    updateMonthYear(from: newDate)
}
```

### Option 2: Direkte Berechnung im View
```swift
Text(monthYearString(from: selectedDate))
    .id(selectedDate)  // Force re-render when date changes
```

### Option 3: Separate @State Variable
```swift
@State private var monthYearText: String = ""

.onChange(of: selectedDate) { newDate in
    monthYearText = formatMonthYear(newDate)
}
```

## Warum meine vorherige Lösung nicht funktioniert hat:

1. **Computed Property wird nicht als State erkannt:**
   - SwiftUI rendert nur neu, wenn `@State` oder `@Published` sich ändern
   - Computed Properties werden nicht automatisch getrackt

2. **DateFormatter wird jedes Mal neu erstellt:**
   - Jeder Aufruf erstellt einen neuen Formatter
   - SwiftUI erkennt möglicherweise keine Änderung

3. **Keine explizite Reaktivität:**
   - Es fehlt ein `onChange` Modifier, der explizit sagt: "Wenn selectedDate sich ändert, aktualisiere den Text"




