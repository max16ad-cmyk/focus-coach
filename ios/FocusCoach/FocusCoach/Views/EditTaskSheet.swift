//
//  EditTaskSheet.swift
//  FocusCoach
//
//  Sheet zum Bearbeiten einer wiederkehrenden Aufgabe
//

import SwiftUI

struct EditTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskRepository = TaskRepository.shared
    
    let task: Task
    
    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var hasTimeSlot: Bool = false
    @State private var repeatPattern: RepeatPattern = .daily
    @State private var repeatWeekdays: RepeatWeekdays = RepeatWeekdays()
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var showWeekdayPicker = false
    
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
                            
                            TextField("Aufgaben-Titel", text: $title)
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
                        
                        // Time Slot Toggle
                        Toggle("Zeit festlegen", isOn: $hasTimeSlot)
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        if hasTimeSlot {
                            HStack(spacing: PremiumTheme.Spacing.md) {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    Text("Von")
                                        .font(.system(size: 12))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(PremiumTheme.Colors.pendingBlue)
                                }
                                
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    Text("Bis")
                                        .font(.system(size: 12))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(PremiumTheme.Colors.pendingBlue)
                                }
                            }
                            .padding()
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
                                
                                // Reset weekdays wenn Pattern wechselt
                                let oldHadWeekdays = (repeatPattern == .weekly || repeatPattern == .weekdays)
                                let newHasWeekdays = (newValue == .weekly || newValue == .weekdays)
                                
                                if oldHadWeekdays && !newHasWeekdays {
                                    repeatWeekdays = RepeatWeekdays()
                                } else if !oldHadWeekdays && newHasWeekdays {
                                    repeatWeekdays = RepeatWeekdays()
                                } else if newValue == .weekdays && repeatPattern != .weekly {
                                    repeatWeekdays = RepeatWeekdays()
                                }
                            }
                            
                            // Wochentags-Auswahl
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
            .navigationTitle("Aufgabe bearbeiten")
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
                        
                        // Lösche alle alten Tasks dieser wiederkehrenden Aufgabe
                        deleteOldRecurringTasks()
                        
                        // Erstelle aktualisierte Task
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let scheduledDateString = dateFormatter.string(from: selectedDate)
                        
                        let timeFormatter = DateFormatter()
                        timeFormatter.dateFormat = "HH:mm"
                        let startTimeString = hasTimeSlot ? timeFormatter.string(from: startTime) : nil
                        let endTimeString = hasTimeSlot ? timeFormatter.string(from: endTime) : nil
                        
                        let updatedTask = Task(
                            id: task.id, // Behalte die gleiche ID
                            title: title.trimmingCharacters(in: .whitespaces),
                            completed: false,
                            status: .pending,
                            scheduledDate: scheduledDateString,
                            scheduledStartTime: startTimeString,
                            scheduledEndTime: endTimeString,
                            repeatPattern: repeatPattern,
                            repeatWeekdays: (repeatPattern == .weekly || repeatPattern == .weekdays) && repeatWeekdays.selectedDays.count > 0 ? repeatWeekdays : nil,
                            notes: notes.isEmpty ? nil : notes,
                            blockListId: task.blockListId,
                            routineId: task.routineId
                        )
                        
                        _Concurrency.Task {
                            do {
                                // Speichere aktualisierte Task
                                try await taskRepository.updateTask(updatedTask)
                                
                                // Erstelle neue wiederkehrende Tasks
                                try await TaskRepeater.shared.createRepeatingTasks(from: updatedTask, daysAhead: 30)
                                
                                await MainActor.run {
                                    isSaving = false
                                    dismiss()
                                }
                            } catch {
                                await MainActor.run {
                                    isSaving = false
                                    print("❌ Fehler beim Speichern der Aufgabe: \(error)")
                                }
                            }
                        }
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || isSaving)
                }
            }
            .onAppear {
                // Lade Task-Daten
                title = task.title
                notes = task.notes ?? ""
                repeatPattern = task.repeatPattern ?? .daily
                repeatWeekdays = task.repeatWeekdays ?? RepeatWeekdays()
                showWeekdayPicker = (task.repeatPattern == .weekly || task.repeatPattern == .weekdays)
                
                // Parse Datum und Zeit
                if let scheduledDateString = task.scheduledDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let date = formatter.date(from: scheduledDateString) {
                        selectedDate = date
                    }
                }
                
                hasTimeSlot = task.hasTimeSlot
                if let startTimeStr = task.scheduledStartTime {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: startTimeStr) {
                        startTime = date
                    }
                }
                if let endTimeStr = task.scheduledEndTime {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: endTimeStr) {
                        endTime = date
                    }
                }
            }
        }
    }
    
    private func deleteOldRecurringTasks() {
        // Lösche alle Tasks mit gleichem Titel und Pattern (alte Instanzen)
        let tasksToDelete = taskRepository.allTasks.filter { existingTask in
            existingTask.title == task.title &&
            existingTask.repeatPattern == task.repeatPattern &&
            existingTask.scheduledStartTime == task.scheduledStartTime &&
            existingTask.scheduledEndTime == task.scheduledEndTime
        }
        
        _Concurrency.Task {
            for taskToDelete in tasksToDelete {
                do {
                    try await taskRepository.deleteTask(taskToDelete.id)
                } catch {
                    print("⚠️ Fehler beim Löschen von Task '\(taskToDelete.title)': \(error)")
                }
            }
        }
    }
}




