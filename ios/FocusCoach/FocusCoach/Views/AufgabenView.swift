//
//  AufgabenView.swift
//  FocusCoach
//
//  Tab für Aufgaben- und Routinen-Erstellung
//

import SwiftUI

struct AufgabenView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    // Verwende @ObservedObject statt @StateObject um sicherzustellen, dass die Singleton-Instanzen verwendet werden
    @ObservedObject private var taskRepository = TaskRepository.shared
    @ObservedObject private var routineRepository = RoutineRepository.shared
    @State private var selectedSection: AufgabenSection = .aufgaben
    @State private var showingNewTask = false
    @State private var showingNewRoutine = false
    
    enum AufgabenSection: String, CaseIterable {
        case aufgaben = "Aufgaben"
        case routinen = "Routinen"
        
        var icon: String {
            switch self {
            case .aufgaben: return "checkmark.circle"
            case .routinen: return "repeat.circle"
            }
        }
    }
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                    Text("Aufgaben & Routinen")
                        .font(PremiumTheme.Typography.headlineLG)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    Text("Erstelle Aufgaben und Routinen für wiederkehrende Aktivitäten")
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, PremiumTheme.Spacing.lg)
                .padding(.top, PremiumTheme.Spacing.lg)
                
                // Section Picker
                HStack(spacing: PremiumTheme.Spacing.sm) {
                    ForEach(AufgabenSection.allCases, id: \.self) { section in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                selectedSection = section
                            }
                        }) {
                            HStack(spacing: PremiumTheme.Spacing.xs) {
                                Image(systemName: section.icon)
                                    .font(.system(size: 14))
                                Text(section.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(selectedSection == section ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textMuted)
                            .padding(.horizontal, PremiumTheme.Spacing.md)
                            .padding(.vertical, PremiumTheme.Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(selectedSection == section ? PremiumTheme.Colors.backgroundCard : Color.clear)
                            )
                        }
                    }
                }
                .padding(.horizontal, PremiumTheme.Spacing.lg)
                .padding(.top, PremiumTheme.Spacing.md)
                .padding(.bottom, PremiumTheme.Spacing.sm)
                
                Divider()
                    .background(PremiumTheme.Colors.borderDefault)
                
                // Content
                ScrollView {
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        if selectedSection == .aufgaben {
                            AufgabenSectionView(showingNewTask: $showingNewTask)
                        } else {
                            RoutinenSectionView(
                                routines: routineRepository.allRoutines,
                                showingNewRoutine: $showingNewRoutine
                            )
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    .padding(.bottom, 100) // Space for FAB
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if selectedSection == .aufgaben {
                            showingNewTask = true
                        } else {
                            showingNewRoutine = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.25),
                                                        Color.white.opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.4),
                                                        Color.white.opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                    }
                    .padding(.trailing, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.lg)
                }
            }
        }
        .sheet(isPresented: $showingNewTask) {
            NewTaskSheetWrapper()
        }
        .sheet(isPresented: $showingNewRoutine) {
            NewRoutineSheet()
                .environmentObject(firebaseService)
        }
    }
}

// MARK: - Aufgaben Section

struct AufgabenSectionView: View {
    @Binding var showingNewTask: Bool
    @ObservedObject private var taskRepository = TaskRepository.shared
    @State private var editingTask: Task?
    @State private var showingDeleteConfirmation = false
    @State private var taskToDelete: Task?
    
    // Wiederkehrende Tasks (Template-Tasks mit repeatPattern)
    private var recurringTasks: [Task] {
        taskRepository.allTasks.filter { $0.repeatPattern != nil }
            .sorted { task1, task2 in
                // Sortiere nach Erstellungsdatum (neueste zuerst)
                let time1 = task1.createdAt ?? 0
                let time2 = task2.createdAt ?? 0
                return time1 > time2
            }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.lg) {
            // Header
            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                Text("Aufgaben")
                    .font(PremiumTheme.Typography.headlineSM)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                
                Text("Erstelle Aufgaben und wiederkehrende Aufgaben für regelmäßige Aktivitäten.")
                    .font(.system(size: 14))
                    .foregroundColor(PremiumTheme.Colors.textMuted)
                    .lineSpacing(4)
            }
            
            // Button zum Erstellen neuer Aufgaben
            Button(action: {
                showingNewTask = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Aufgabe erstellen")
                        .font(PremiumTheme.Typography.bodyMD)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(PremiumTheme.Colors.textPrimary)
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
            
            // Wiederkehrende Aufgaben Liste
            if recurringTasks.isEmpty {
                VStack(spacing: PremiumTheme.Spacing.md) {
                    Image(systemName: "repeat.circle")
                        .font(.system(size: 48))
                        .foregroundColor(PremiumTheme.Colors.textMuted.opacity(0.5))
                    
                    Text("Noch keine wiederkehrenden Aufgaben")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                    
                    Text("Erstelle deine erste wiederkehrende Aufgabe")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.textMuted.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, PremiumTheme.Spacing.xxl)
            } else {
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                    Text("Wiederkehrende Aufgaben")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                        .padding(.top, PremiumTheme.Spacing.md)
                    
                    ScrollView {
                        VStack(spacing: PremiumTheme.Spacing.md) {
                            ForEach(recurringTasks) { task in
                                SwipeableTaskCard(
                                    task: task,
                                    onTap: {
                                        editingTask = task
                                    },
                                    onDelete: {
                                        taskToDelete = task
                                        showingDeleteConfirmation = true
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $editingTask) { task in
            EditTaskSheet(task: task)
        }
        .alert("Wiederkehrende Aufgabe löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {
                taskToDelete = nil
            }
            Button("Löschen", role: .destructive) {
                if let task = taskToDelete {
                    deleteRecurringTask(task)
                }
            }
        } message: {
            if let task = taskToDelete {
                Text("Möchtest du '\(task.title)' wirklich löschen? Alle wiederkehrenden Instanzen dieser Aufgabe werden ebenfalls gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
    }
    
    private func deleteRecurringTask(_ task: Task) {
        _Concurrency.Task {
            do {
                // Lösche alle Tasks mit gleichem Titel und Pattern
                let tasksToDelete = taskRepository.allTasks.filter { existingTask in
                    existingTask.title == task.title &&
                    existingTask.repeatPattern == task.repeatPattern &&
                    existingTask.scheduledStartTime == task.scheduledStartTime &&
                    existingTask.scheduledEndTime == task.scheduledEndTime
                }
                
                print("🗑️ Lösche \(tasksToDelete.count) Tasks für wiederkehrende Aufgabe '\(task.title)'")
                
                for taskToDelete in tasksToDelete {
                    try await taskRepository.deleteTask(taskToDelete.id)
                }
                
                print("✅ Alle Tasks für wiederkehrende Aufgabe '\(task.title)' gelöscht")
            } catch {
                print("❌ Fehler beim Löschen der wiederkehrenden Aufgabe: \(error)")
            }
        }
    }
}

// MARK: - Routinen Section

struct RoutinenSectionView: View {
    let routines: [Routine]
    @Binding var showingNewRoutine: Bool
    @StateObject private var routineRepository = RoutineRepository.shared
    @State private var editingRoutine: Routine?
    @State private var showingDeleteConfirmation = false
    @State private var routineToDelete: Routine?
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.lg) {
            // Header
            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                Text("Routinen")
                    .font(PremiumTheme.Typography.headlineSM)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                
                Text("Erstelle Routinen für wiederkehrende Aktivitäten wie Morgen Routine, Sport oder Abend Routine.")
                    .font(.system(size: 14))
                    .foregroundColor(PremiumTheme.Colors.textMuted)
                    .lineSpacing(4)
            }
            
            // Routinen Liste
            if routines.isEmpty {
                VStack(spacing: PremiumTheme.Spacing.md) {
                    Image(systemName: "repeat.circle")
                        .font(.system(size: 48))
                        .foregroundColor(PremiumTheme.Colors.textMuted.opacity(0.5))
                    
                    Text("Noch keine Routinen")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                    
                    Text("Erstelle deine erste Routine")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.textMuted.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, PremiumTheme.Spacing.xxl)
            } else {
                ScrollView {
                    VStack(spacing: PremiumTheme.Spacing.md) {
                        ForEach(routines) { routine in
                            SwipeableRoutineCard(
                                routine: routine,
                                onTap: {
                                    editingRoutine = routine
                                },
                                onDelete: {
                                    routineToDelete = routine
                                    showingDeleteConfirmation = true
                                }
                            )
                        }
                    }
                }
            }
        }
        .sheet(item: $editingRoutine) { routine in
            EditRoutineSheet(routine: routine)
        }
        .alert("Routine löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {
                routineToDelete = nil
            }
            Button("Löschen", role: .destructive) {
                if let routine = routineToDelete {
                    deleteRoutine(routine)
                }
            }
        } message: {
            if let routine = routineToDelete {
                Text("Möchtest du '\(routine.name)' wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
    }
    
    private func deleteRoutine(_ routine: Routine) {
        _Concurrency.Task {
            do {
                try await routineRepository.deleteRoutine(routine.id)
                print("✅ Routine gelöscht: \(routine.name)")
            } catch {
                print("❌ Fehler beim Löschen der Routine: \(error)")
            }
        }
    }
}

// MARK: - Routine Card

struct RoutineCard: View {
    let routine: Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    Text(routine.name)
                        .font(PremiumTheme.Typography.headlineSM)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    if let description = routine.description {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: PremiumTheme.Spacing.md) {
                        Label("\(routine.tasks.count) Tasks", systemImage: "list.bullet")
                            .font(.system(size: 12))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                        
                        Label(routine.repeatPattern.rawValue, systemImage: "repeat")
                            .font(.system(size: 12))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                }
                
                Spacer()
                
                if routine.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(PremiumTheme.Colors.productivityGreen)
                }
            }
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

// MARK: - New Routine Sheet

struct NewRoutineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var routineRepository = RoutineRepository.shared
    @EnvironmentObject var firebaseService: FirebaseService
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var repeatPattern: RepeatPattern = .daily
    @State private var repeatWeekdays: RepeatWeekdays = RepeatWeekdays()
    @State private var routineTasks: [RoutineTask] = []
    @State private var showingAddTask = false
    @State private var isSaving = false
    @State private var showWeekdayPicker = false
    
    var isEditMode: Bool { false }
    
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
                                ForEach(routineTasks.sorted(by: { $0.order < $1.order })) { task in
                                    RoutineTaskRow(task: task)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                }
            }
            .navigationTitle(isEditMode ? "Routine bearbeiten" : "Neue Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Speichern" : "Erstellen") {
                        guard !isSaving else { return }
                        
                        isSaving = true
                        
                        let routine = Routine(
                            id: UUID().uuidString,
                            name: name,
                            description: description.isEmpty ? nil : description,
                            tasks: routineTasks,
                            repeatPattern: repeatPattern,
                            repeatWeekdays: (repeatPattern == .weekly || repeatPattern == .weekdays) && repeatWeekdays.selectedDays.count > 0 ? repeatWeekdays : nil,
                            isActive: true
                        )
                        
                        _Concurrency.Task {
                            do {
                                // Speichere Routine (ohne Tasks zu erstellen - das passiert asynchron)
                                try await firebaseService.saveRoutine(routine)
                                
                                // Erstelle Tasks asynchron im Hintergrund (nicht blockierend)
                                _Concurrency.Task.detached(priority: .background) {
                                    do {
                                        try await RoutineRepository.shared.createTasksFromRoutine(routine)
                                    } catch {
                                        print("⚠️ Fehler beim Erstellen von Tasks aus Routine: \(error)")
                                    }
                                }
                                
                                await MainActor.run {
                                    isSaving = false
                                    dismiss()
                                }
                            } catch {
                                await MainActor.run {
                                    isSaving = false
                                    print("❌ Fehler beim Speichern der Routine: \(error)")
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
                NewRoutineTaskSheet(routineTasks: $routineTasks)
            }
        }
    }
}

// MARK: - Routine Task Row

struct RoutineTaskRow: View {
    let task: RoutineTask
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                
                if let startTime = task.startTime, let endTime = task.endTime {
                    Text("\(startTime) - \(endTime)")
                        .font(.system(size: 12))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                }
            }
            
            Spacer()
        }
        .padding(PremiumTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
        )
    }
}

// MARK: - New Routine Task Sheet

struct NewRoutineTaskSheet: View {
    @Binding var routineTasks: [RoutineTask]
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
            .navigationTitle("Task hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialisiere Date-Objekte aus Strings falls vorhanden
                if !startTime.isEmpty {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: startTime) {
                        startTimeDate = date
                    }
                }
                if !endTime.isEmpty {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: endTime) {
                        endTimeDate = date
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        let task = RoutineTask(
                            title: title,
                            startTime: startTime.isEmpty ? nil : startTime,
                            endTime: endTime.isEmpty ? nil : endTime,
                            notes: notes.isEmpty ? nil : notes,
                            order: routineTasks.count
                        )
                        routineTasks.append(task)
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

