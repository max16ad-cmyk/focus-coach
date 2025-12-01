//
//  EditRoutineSheet.swift
//  FocusCoach
//
//  Sheet zum Bearbeiten einer bestehenden Routine
//

import SwiftUI

struct EditRoutineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var routineRepository = RoutineRepository.shared
    @EnvironmentObject var firebaseService: FirebaseService
    
    let routine: Routine
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var repeatPattern: RepeatPattern = .daily
    @State private var repeatWeekdays: RepeatWeekdays = RepeatWeekdays()
    @State private var routineTasks: [RoutineTask] = []
    @State private var showingAddTask = false
    @State private var isSaving = false
    @State private var editingTaskIndex: Int?
    @State private var showWeekdayPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumTheme.Colors.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        // Name
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Name")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            TextField("z.B. Morgen Routine", text: $name)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .autocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .textInputAutocapitalization(.sentences)
                                .keyboardType(.default)
                                .submitLabel(.next)
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Beschreibung (optional)")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            TextField("Beschreibung der Routine", text: $description)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .autocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .textInputAutocapitalization(.sentences)
                                .keyboardType(.default)
                                .submitLabel(.next)
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Repeat Pattern
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Wiederholung")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            Picker("Wiederholung", selection: $repeatPattern) {
                                Text("Täglich").tag(RepeatPattern.daily)
                                Text("Wöchentlich").tag(RepeatPattern.weekly)
                                Text("Monatlich").tag(RepeatPattern.monthly)
                                Text("Bestimmte Wochentage").tag(RepeatPattern.weekdays)
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: repeatPattern) { newValue in
                                showWeekdayPicker = (newValue == .weekly || newValue == .weekdays)
                                
                                // Wenn man von einem Pattern mit Wochentagen zu einem ohne wechselt,
                                // oder umgekehrt, resetze die Wochentage
                                let oldHadWeekdays = (repeatPattern == .weekly || repeatPattern == .weekdays)
                                let newHasWeekdays = (newValue == .weekly || newValue == .weekdays)
                                
                                if oldHadWeekdays && !newHasWeekdays {
                                    // Von Wochentagen zu täglich/monatlich: Reset
                                    repeatWeekdays = RepeatWeekdays()
                                } else if !oldHadWeekdays && newHasWeekdays {
                                    // Von täglich/monatlich zu Wochentagen: Reset (Benutzer soll neu wählen)
                                    repeatWeekdays = RepeatWeekdays()
                                } else if newValue == .weekdays {
                                    // Bei "Bestimmte Wochentage" sollte man immer neu wählen können
                                    // Reset nur wenn man von "Wöchentlich" kommt
                                    if repeatPattern == .weekly {
                                        // Behalte die aktuellen Wochentage wenn man von "Wöchentlich" kommt
                                    } else {
                                        // Reset wenn man von anderen Patterns kommt
                                        repeatWeekdays = RepeatWeekdays()
                                    }
                                }
                            }
                            
                            // Wochentags-Auswahl für wöchentlich oder bestimmte Wochentage
                            if showWeekdayPicker {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                    Text("Wochentage auswählen")
                                        .font(.system(size: 13))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    HStack(spacing: PremiumTheme.Spacing.xs) {
                                        WeekdayToggle(day: "Mo", isSelected: $repeatWeekdays.monday)
                                        WeekdayToggle(day: "Di", isSelected: $repeatWeekdays.tuesday)
                                        WeekdayToggle(day: "Mi", isSelected: $repeatWeekdays.wednesday)
                                        WeekdayToggle(day: "Do", isSelected: $repeatWeekdays.thursday)
                                        WeekdayToggle(day: "Fr", isSelected: $repeatWeekdays.friday)
                                        WeekdayToggle(day: "Sa", isSelected: $repeatWeekdays.saturday)
                                        WeekdayToggle(day: "So", isSelected: $repeatWeekdays.sunday)
                                    }
                                    
                                    if !repeatWeekdays.displayText.isEmpty {
                                        Text("Ausgewählt: \(repeatWeekdays.displayText)")
                                            .font(.system(size: 12))
                                            .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                            .padding(.top, PremiumTheme.Spacing.xs)
                                    }
                                }
                                .padding(.top, PremiumTheme.Spacing.sm)
                            }
                        }
                        
                        // Tasks
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            HStack {
                                Text("Tasks")
                                    .font(PremiumTheme.Typography.headlineSM)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAddTask = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                }
                            }
                            
                            if routineTasks.isEmpty {
                                Text("Noch keine Tasks hinzugefügt")
                                    .font(.system(size: 14))
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                    .padding(.top, PremiumTheme.Spacing.sm)
                            } else {
                                ForEach(Array(routineTasks.sorted(by: { $0.order < $1.order }).enumerated()), id: \.element.id) { index, task in
                                    SwipeableRoutineTaskRow(
                                        task: task,
                                        onEdit: {
                                            editingTaskIndex = index
                                            showingAddTask = true
                                        },
                                        onDelete: {
                                            routineTasks.removeAll { $0.id == task.id }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                }
            }
            .navigationTitle("Routine bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        guard !isSaving else { return }
                        
                        isSaving = true
                        
                        var updatedRoutine = routine
                        updatedRoutine.name = name
                        updatedRoutine.description = description.isEmpty ? nil : description
                        updatedRoutine.tasks = routineTasks
                        updatedRoutine.repeatPattern = repeatPattern
                        
                        // Speichere repeatWeekdays nur wenn ein Pattern mit Wochentagen gewählt ist
                        // UND mindestens ein Wochentag ausgewählt wurde
                        print("🔍 EditRoutineSheet: Vor dem Speichern - repeatPattern: \(repeatPattern.rawValue)")
                        print("   - repeatWeekdays State: Mo=\(repeatWeekdays.monday), Di=\(repeatWeekdays.tuesday), Mi=\(repeatWeekdays.wednesday), Do=\(repeatWeekdays.thursday), Fr=\(repeatWeekdays.friday), Sa=\(repeatWeekdays.saturday), So=\(repeatWeekdays.sunday)")
                        
                        if (repeatPattern == .weekly || repeatPattern == .weekdays) {
                            // Prüfe ob mindestens ein Tag ausgewählt ist
                            let hasSelectedDays = repeatWeekdays.monday || repeatWeekdays.tuesday || 
                                                repeatWeekdays.wednesday || repeatWeekdays.thursday || 
                                                repeatWeekdays.friday || repeatWeekdays.saturday || 
                                                repeatWeekdays.sunday
                            
                            if hasSelectedDays {
                                // Erstelle eine KOPIE von repeatWeekdays, um sicherzustellen, dass die Werte korrekt sind
                                var weekdaysToSave = RepeatWeekdays()
                                weekdaysToSave.monday = repeatWeekdays.monday
                                weekdaysToSave.tuesday = repeatWeekdays.tuesday
                                weekdaysToSave.wednesday = repeatWeekdays.wednesday
                                weekdaysToSave.thursday = repeatWeekdays.thursday
                                weekdaysToSave.friday = repeatWeekdays.friday
                                weekdaysToSave.saturday = repeatWeekdays.saturday
                                weekdaysToSave.sunday = repeatWeekdays.sunday
                                
                                updatedRoutine.repeatWeekdays = weekdaysToSave
                                print("✅ EditRoutineSheet: Speichere repeatWeekdays mit \(weekdaysToSave.selectedDays.count) Tagen: \(weekdaysToSave.displayText)")
                            } else {
                                updatedRoutine.repeatWeekdays = nil
                                print("⚠️ EditRoutineSheet: Keine Wochentage ausgewählt - setze repeatWeekdays auf nil")
                            }
                        } else {
                            updatedRoutine.repeatWeekdays = nil
                            print("ℹ️ EditRoutineSheet: Pattern ist nicht weekly/weekdays - setze repeatWeekdays auf nil")
                        }
                        
                        updatedRoutine.updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
                        
                        print("💾 EditRoutineSheet: Speichere Routine '\(updatedRoutine.name)'")
                        print("   - repeatPattern: \(updatedRoutine.repeatPattern.rawValue)")
                        print("   - repeatWeekdays: \(updatedRoutine.repeatWeekdays?.displayText ?? "nil")")
                        
                        _Concurrency.Task {
                            do {
                                try await routineRepository.updateRoutine(updatedRoutine)
                                
                                await MainActor.run {
                                    isSaving = false
                                    dismiss()
                                }
                            } catch {
                                await MainActor.run {
                                    isSaving = false
                                    print("❌ Fehler beim Aktualisieren der Routine: \(error)")
                                }
                            }
                        }
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .sheet(isPresented: $showingAddTask) {
                if let index = editingTaskIndex {
                    EditRoutineTaskSheet(
                        routineTasks: $routineTasks,
                        taskToEdit: routineTasks.sorted(by: { $0.order < $1.order })[index]
                    )
                    .onDisappear {
                        editingTaskIndex = nil
                    }
                } else {
                    NewRoutineTaskSheet(routineTasks: $routineTasks)
                }
            }
            .onAppear {
                // Lade Routine-Daten
                name = routine.name
                description = routine.description ?? ""
                repeatPattern = routine.repeatPattern
                repeatWeekdays = routine.repeatWeekdays ?? RepeatWeekdays()
                routineTasks = routine.tasks
                showWeekdayPicker = (routine.repeatPattern == .weekly || routine.repeatPattern == .weekdays)
                
                print("📖 EditRoutineSheet: Lade Routine '\(routine.name)'")
                print("   - repeatPattern: \(routine.repeatPattern.rawValue)")
                print("   - repeatWeekdays: \(routine.repeatWeekdays?.displayText ?? "nil")")
                if let weekdays = routine.repeatWeekdays {
                    print("   - Wochentage: Mo=\(weekdays.monday), Di=\(weekdays.tuesday), Mi=\(weekdays.wednesday), Do=\(weekdays.thursday), Fr=\(weekdays.friday), Sa=\(weekdays.saturday), So=\(weekdays.sunday)")
                }
            }
        }
    }
}

// MARK: - Edit Routine Task Sheet

struct EditRoutineTaskSheet: View {
    @Binding var routineTasks: [RoutineTask]
    let taskToEdit: RoutineTask
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var notes: String = ""
    
    // Date-Objekte für DatePicker
    @State private var startTimeDate: Date = Date()
    @State private var endTimeDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumTheme.Colors.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        // Title
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Titel")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            TextField("Task-Titel", text: $title)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .autocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .textInputAutocapitalization(.sentences)
                                .keyboardType(.default)
                                .submitLabel(.next)
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Time
                        HStack(spacing: PremiumTheme.Spacing.md) {
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                Text("Startzeit")
                                    .font(PremiumTheme.Typography.bodyMD)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                
                                DatePicker("", selection: $startTimeDate, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(PremiumTheme.Colors.pendingBlue)
                                    .onChange(of: startTimeDate) { newDate in
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm"
                                        startTime = formatter.string(from: newDate)
                                    }
                                    .padding(PremiumTheme.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                            .fill(PremiumTheme.Colors.backgroundCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                    .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                            )
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                Text("Endzeit")
                                    .font(PremiumTheme.Typography.bodyMD)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                
                                DatePicker("", selection: $endTimeDate, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(PremiumTheme.Colors.pendingBlue)
                                    .onChange(of: endTimeDate) { newDate in
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm"
                                        endTime = formatter.string(from: newDate)
                                    }
                                    .padding(PremiumTheme.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                            .fill(PremiumTheme.Colors.backgroundCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                    .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Notizen (optional)")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            TextField("Notizen", text: $notes, axis: .vertical)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .autocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .textInputAutocapitalization(.sentences)
                                .keyboardType(.default)
                                .submitLabel(.done)
                                .lineLimit(3...6)
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                }
            }
            .navigationTitle("Task bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        // Konvertiere Date zu String falls noch nicht gesetzt
                        if startTime.isEmpty {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            startTime = formatter.string(from: startTimeDate)
                        }
                        if endTime.isEmpty {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            endTime = formatter.string(from: endTimeDate)
                        }
                        
                        if let index = routineTasks.firstIndex(where: { $0.id == taskToEdit.id }) {
                            routineTasks[index] = RoutineTask(
                                id: taskToEdit.id,
                                title: title,
                                startTime: startTime.isEmpty ? nil : startTime,
                                endTime: endTime.isEmpty ? nil : endTime,
                                notes: notes.isEmpty ? nil : notes,
                                order: taskToEdit.order
                            )
                        }
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                title = taskToEdit.title
                startTime = taskToEdit.startTime ?? ""
                endTime = taskToEdit.endTime ?? ""
                notes = taskToEdit.notes ?? ""
                
                // Initialisiere Date-Objekte aus Strings
                if let startTimeStr = taskToEdit.startTime, !startTimeStr.isEmpty {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: startTimeStr) {
                        startTimeDate = date
                    }
                }
                if let endTimeStr = taskToEdit.endTime, !endTimeStr.isEmpty {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: endTimeStr) {
                        endTimeDate = date
                    }
                }
            }
        }
    }
}

