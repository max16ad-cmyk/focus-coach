//
//  HeuteView.swift
//  FocusCoach
//
//  Tab 1: HEUTE - Today's tasks and quick notes
//

import SwiftUI

struct HeuteView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @StateObject private var blockingMonitor = TaskBlockingMonitor.shared
    @StateObject private var taskRepository = TaskRepository.shared
    @ObservedObject private var routineRepository = RoutineRepository.shared
    @State private var quickNote: String = ""
    @State private var showingNewTask = false
    @State private var showingSettings = false
    @State private var newTaskText = ""
    @State private var newTaskStartTime: String?
    @State private var newTaskEndTime: String?
    @State private var newTaskDate: Date = Date()
    @State private var newTaskRepeatPattern: RepeatPattern? = nil
    @State private var newTaskRepeatWeekdays: RepeatWeekdays? = nil
    @State private var newTaskNotes: String = ""
    @State private var newTaskBlockListId: String? = nil
    
    // Block-System State
    @State private var draggedTask: Task?
    @State private var editingTask: Task?
    @State private var showingBlockEditor = false
    
    // Calendar state
    @State private var selectedDate: Date = Date()
    @State private var showCalendar = false
    @State private var currentMonth: Date = Date()
    @State private var displayedMonthYear: String = "" // Explizite State-Variable für Header
    
    // DateFormatter als statische Variable (wird nur einmal erstellt)
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    // Calendar helpers
    private var monthYearString: String {
        // Verwende displayedMonthYear wenn gesetzt, sonst berechne aus selectedDate
        if !displayedMonthYear.isEmpty {
            return displayedMonthYear
        }
        return Self.monthYearFormatter.string(from: selectedDate)
    }
    
    // Aktualisiert displayedMonthYear basierend auf einem Datum
    private func updateMonthYear(from date: Date) {
        let newMonthYear = Self.monthYearFormatter.string(from: date)
        if displayedMonthYear != newMonthYear {
            displayedMonthYear = newMonthYear
        }
    }
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
    
    // Computed property for selected date's tasks (nur Top-Level Tasks)
    private var tasksForSelectedDate: [Task] {
        var dateTasks = taskRepository.getTasksForDate(selectedDate)
        
        // If selected date is today, also include tasks without date
        if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
            let tasksWithoutDate = taskRepository.allTasks.filter { $0.scheduledDate == nil }
            dateTasks.append(contentsOf: tasksWithoutDate)
        }
        
        // Filter: nur Top-Level Tasks (ohne parentTaskId)
        let topLevelTasks = dateTasks.filter { $0.parentTaskId == nil }
        
        // Sort: pending first, then completed, then by time
        return topLevelTasks.sorted { task1, task2 in
            if task1.completed != task2.completed {
                return !task1.completed && task2.completed
            }
            if task1.hasTimeSlot && task2.hasTimeSlot {
                guard let time1 = task1.scheduledStartTime,
                      let time2 = task2.scheduledStartTime else { return false }
                return time1 < time2
            }
            let order1 = task1.order ?? Int((task1.createdAt ?? 0) / 1000)
            let order2 = task2.order ?? Int((task2.createdAt ?? 0) / 1000)
            return order1 < order2
        }
    }
    
    private var tasksWithTime: [Task] {
        tasksForSelectedDate.filter { $0.hasTimeSlot && !$0.completed }
    }
    
    private var tasksWithoutTime: [Task] {
        tasksForSelectedDate.filter { !$0.hasTimeSlot && !$0.completed }
    }
    
    private var completedTasks: [Task] {
        tasksForSelectedDate.filter { $0.completed }
    }
    
    // Routinen-Tasks gruppiert nach routineId
    private var routineTasksGrouped: [String: [Task]] {
        let routineTasks = tasksForSelectedDate.filter { $0.routineId != nil && !$0.completed }
        return Dictionary(grouping: routineTasks) { $0.routineId ?? "" }
    }
    
    // Normale Tasks (ohne Routinen)
    private var normalTasks: [Task] {
        tasksForSelectedDate.filter { $0.routineId == nil }
    }
    
    // Normale Tasks mit Zeit
    private var normalTasksWithTime: [Task] {
        normalTasks.filter { $0.hasTimeSlot && !$0.completed }
    }
    
    // Normale Tasks ohne Zeit
    private var normalTasksWithoutTime: [Task] {
        normalTasks.filter { !$0.hasTimeSlot && !$0.completed }
    }
    
    // Normale completed Tasks
    private var normalCompletedTasks: [Task] {
        normalTasks.filter { $0.completed }
    }
    
    // Helper: Get Routine Name by ID
    private func getRoutineName(for routineId: String) -> String {
        return routineRepository.allRoutines.first(where: { $0.id == routineId })?.name ?? "Routine"
    }
    
    // Helper: Sort Tasks by Time
    private func sortTasksByTime(_ tasks: [Task]) -> [Task] {
        return tasks.sorted { task1, task2 in
            if task1.hasTimeSlot && task2.hasTimeSlot {
                guard let time1 = task1.scheduledStartTime,
                      let time2 = task2.scheduledStartTime else { return false }
                return time1 < time2
            }
            return task1.hasTimeSlot && !task2.hasTimeSlot
        }
    }
    
    private func navigateMonth(_ direction: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: direction, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Calendar Header with Expand Button
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.2)) {
                                showCalendar.toggle()
                            }
                        }) {
                            HStack(spacing: PremiumTheme.Spacing.sm) {
                                Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12))
                                Text(monthYearString)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        }
                        
                        Spacer()
                        
                        // Navigation Buttons
                        HStack(spacing: PremiumTheme.Spacing.md) {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.2)) {
                                    navigateMonth(-1)
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.2)) {
                                    navigateMonth(1)
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                            }
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    
                    // Expanded Calendar View
                    if showCalendar {
                        ExpandedCalendarView(
                            selectedDate: $selectedDate,
                            currentMonth: $currentMonth
                        )
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                        .padding(.top, PremiumTheme.Spacing.md)
                        .calendarSwipeGesture(selectedDate: $selectedDate, currentMonth: $currentMonth)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95))
                        ))
                    }
                    
                    // Scrollable Day Bar (only visible when calendar is collapsed)
                    if !showCalendar {
                        ScrollableDayBar(
                            selectedDate: $selectedDate,
                            currentMonth: $currentMonth
                        )
                        .padding(.top, PremiumTheme.Spacing.md)
                        .frame(height: 70)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95))
                        ))
                    }
                    
                    Divider()
                        .background(PremiumTheme.Colors.borderDefault)
                        .padding(.top, PremiumTheme.Spacing.md)
                    
                    // Tasks for selected date - Grouped by time
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.lg) {
                        if tasksForSelectedDate.isEmpty {
                            VStack(spacing: PremiumTheme.Spacing.md) {
                                Text("Keine Aufgaben geplant")
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                                    .padding(.top, PremiumTheme.Spacing.xxl)
                            }
                        } else {
                            // ROUTINEN-BLÖCKE (Priorität - werden zuerst angezeigt)
                            ForEach(Array(routineTasksGrouped.keys.sorted()), id: \.self) { routineId in
                                if let routineTasks = routineTasksGrouped[routineId], !routineTasks.isEmpty {
                                    let sortedRoutineTasks = sortTasksByTime(routineTasks)
                                    
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                        // Routine Header
                                        HStack(spacing: PremiumTheme.Spacing.xs) {
                                            Image(systemName: "repeat.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                            Text(getRoutineName(for: routineId))
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                            Spacer()
                                            Text("\(sortedRoutineTasks.count)")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                                .padding(.horizontal, PremiumTheme.Spacing.sm)
                                                .padding(.vertical, 4)
                                                .background(
                                                    Capsule()
                                                        .fill(PremiumTheme.Colors.backgroundCard)
                                                )
                                        }
                                        .padding(.bottom, PremiumTheme.Spacing.xs)
                                        
                                        // Routine Tasks
                                        ForEach(sortedRoutineTasks) { task in
                                            PlannedTaskRow(
                                                task: task,
                                                showTime: task.hasTimeSlot,
                                                onToggle: {
                                                    toggleTask(task)
                                                }
                                            )
                                        }
                                    }
                                    .padding(.vertical, PremiumTheme.Spacing.md)
                                    .padding(.horizontal, PremiumTheme.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                            .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                    .stroke(PremiumTheme.Colors.pendingBlue.opacity(0.3), lineWidth: 1.5)
                                            )
                                    )
                                    .padding(.bottom, PremiumTheme.Spacing.md)
                                }
                            }
                            
                            // BLOCK-SYSTEM: Top-Level Tasks mit Drag & Drop
                            let topLevelTasks = tasksForSelectedDate.filter { task in
                                // Exkludiere Routine-Tasks (werden oben angezeigt)
                                task.routineId == nil
                            }
                            
                            if !topLevelTasks.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                                    // Section Header
                                    HStack(spacing: PremiumTheme.Spacing.xs) {
                                        Image(systemName: "square.stack.3d.up")
                                            .font(.system(size: 14))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                        Text("Aufgaben")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                    }
                                    .padding(.top, routineTasksGrouped.isEmpty ? 0 : PremiumTheme.Spacing.md)
                                    .padding(.bottom, PremiumTheme.Spacing.xs)
                                    
                                    // Task Blocks mit Drag & Drop
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                        ForEach(topLevelTasks) { task in
                                            TaskBlock(
                                                task: task,
                                                allTasks: taskRepository.allTasks,
                                                level: 0,
                                                taskRepository: taskRepository,
                                                isDragging: draggedTask?.id == task.id,
                                                dropTarget: false,
                                                dropPosition: nil,
                                                onToggle: {
                                                    toggleTask(task)
                                                },
                                                onTap: {
                                                    editingTask = task
                                                    showingBlockEditor = true
                                                },
                                                onDragStart: {
                                                    draggedTask = task
                                                },
                                                onDragEnd: {
                                                    draggedTask = nil
                                                },
                                                onDrop: { droppedTaskId, position in
                                                    handleDrop(droppedTaskId: droppedTaskId, targetTaskId: task.id, position: position)
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    .padding(.bottom, 100) // Space for FAB
                }
            }
            
            // Floating Action Buttons - + and Microphone
            VStack {
                Spacer()
                HStack(spacing: PremiumTheme.Spacing.md) {
                    Spacer()
                    
                    // Voice Input Button - speichert direkt, kein Callback nötig
                    VoiceInputButton()
                        .padding(.trailing, PremiumTheme.Spacing.sm)
                    
                    // Add Task Button
                    Button(action: { showingNewTask = true }) {
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
        .onAppear {
            // Stelle sicher, dass beim App-Start UND beim Zurückkommen das aktuelle Datum ausgewählt ist
            let today = Date()
            let calendar = Calendar.current
            let todayStartOfDay = calendar.startOfDay(for: today)
            
            // Setze selectedDate IMMER auf heute beim Start/Zurückkommen
            if !calendar.isDate(selectedDate, inSameDayAs: today) {
                selectedDate = todayStartOfDay
            }
            
            // Stelle sicher, dass currentMonth auch auf den aktuellen Monat zeigt
            let todayMonth = calendar.component(.month, from: today)
            let todayYear = calendar.component(.year, from: today)
            if let todayMonthDate = calendar.date(from: DateComponents(year: todayYear, month: todayMonth, day: 1)) {
                currentMonth = todayMonthDate
            }
            
            // Initialisiere displayedMonthYear
            updateMonthYear(from: selectedDate)
            
            // WICHTIG: Trigger auch das Scrolling im ScrollableDayBar
            // Das passiert automatisch durch selectedDate = todayStartOfDay,
            // aber wir stellen sicher, dass es auch wirklich passiert
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Stelle sicher, dass selectedDate wirklich heute ist
                if !calendar.isDate(selectedDate, inSameDayAs: today) {
                    selectedDate = todayStartOfDay
                }
            }
            
            // Tasks werden automatisch über TaskRepository Real-time Sync geladen
        }
        .onChange(of: selectedDate) { newDate in
            // Update displayedMonthYear IMMER wenn selectedDate sich ändert (auch beim Swipen!)
            updateMonthYear(from: newDate)
        }
        .onChange(of: currentMonth) { newMonth in
            // Update displayedMonthYear wenn currentMonth sich ändert (während des Scrollens!)
            // Verwende den ersten Tag des Monats für die Anzeige
            updateMonthYear(from: newMonth)
        }
        .sheet(isPresented: $showingBlockEditor) {
            if let task = editingTask {
                BlockEditorView(task: task)
            }
        }
        .sheet(isPresented: $showingNewTask) {
            NewTaskSheet(
                taskText: $newTaskText,
                selectedDate: $newTaskDate,
                repeatPattern: $newTaskRepeatPattern,
                repeatWeekdays: $newTaskRepeatWeekdays,
                initialStartTime: newTaskStartTime,
                initialEndTime: newTaskEndTime,
                initialNotes: newTaskNotes.isEmpty ? nil : newTaskNotes,
                onSave: { startTime, endTime, date, repeatPattern, repeatWeekdays, notes, blockListId in
                    newTaskStartTime = startTime
                    newTaskEndTime = endTime
                    newTaskDate = date
                    newTaskRepeatPattern = repeatPattern
                    newTaskRepeatWeekdays = repeatWeekdays
                    newTaskNotes = notes ?? ""
                    newTaskBlockListId = blockListId
                    addTask()
                    showingNewTask = false
                    newTaskText = ""
                    newTaskStartTime = nil
                    newTaskEndTime = nil
                    newTaskDate = Date()
                    newTaskRepeatPattern = nil
                    newTaskRepeatWeekdays = nil
                    newTaskNotes = ""
                    newTaskBlockListId = nil
                },
                onCancel: {
                    showingNewTask = false
                    newTaskText = ""
                    newTaskStartTime = nil
                    newTaskEndTime = nil
                    newTaskDate = Date()
                    newTaskRepeatPattern = nil
                    newTaskRepeatWeekdays = nil
                    newTaskNotes = ""
                }
            )
        }
    }
    
    private func toggleTask(_ task: Task) {
        _Concurrency.Task {
            do {
                try await taskRepository.toggleTaskCompletion(task)
                // Real-time listener wird automatisch aktualisiert
            } catch {
                print("❌ Error toggling task: \(error)")
            }
        }
    }
    
    private func deleteTask(_ task: Task) {
        _Concurrency.Task {
            do {
                try await taskRepository.deleteTask(task.id)
                // Real-time listener wird automatisch aktualisiert
            } catch {
                print("❌ Error deleting task: \(error)")
            }
        }
    }
    
    private func addTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let scheduledDateString = dateFormatter.string(from: newTaskDate)
        
        // If no time slot and no date selected (today), don't set scheduledDate
        let shouldSetDate = (newTaskStartTime != nil && newTaskEndTime != nil) || !Calendar.current.isDate(newTaskDate, inSameDayAs: Date())
        
        let task = Task(
            title: newTaskText.trimmingCharacters(in: .whitespaces),
            completed: false,
            status: .pending,
            scheduledDate: shouldSetDate ? scheduledDateString : nil,
            scheduledStartTime: newTaskStartTime,
            scheduledEndTime: newTaskEndTime,
            repeatPattern: newTaskRepeatPattern,
            repeatWeekdays: newTaskRepeatWeekdays,
            notes: newTaskNotes.isEmpty ? nil : newTaskNotes,
            blockListId: newTaskBlockListId
        )
        
        // Save task centrally via TaskRepository
        _Concurrency.Task {
            do {
                try await taskRepository.saveTask(task)
                await MainActor.run {
                    // Reset form
                    newTaskText = ""
                    newTaskStartTime = nil
                    newTaskEndTime = nil
                    newTaskDate = Date()
                    newTaskRepeatPattern = nil
                    newTaskRepeatWeekdays = nil
                    newTaskNotes = ""
                    showingNewTask = false
                }
            } catch {
                print("❌ Error saving task: \(error)")
            }
        }
    }
    
    private func saveQuickNote() {
        // Save quick note to UserDefaults or Firebase
        let todayString = selectedDateString
        UserDefaults.standard.set(quickNote, forKey: "quickNote_\(todayString)")
    }
    
    private func handleDrop(droppedTaskId: String, targetTaskId: String, position: TaskBlock.DropPosition) {
        guard let droppedTask = taskRepository.allTasks.first(where: { $0.id == droppedTaskId }),
              let targetTask = taskRepository.allTasks.first(where: { $0.id == targetTaskId }) else {
            return
        }
        
        _Concurrency.Task {
            do {
                switch position {
                case .above:
                    // Verschiebe Task über den Target-Task
                    let targetOrder = targetTask.order ?? 0
                    try await taskRepository.moveTask(taskId: droppedTaskId, newParentId: targetTask.parentTaskId, newOrder: targetOrder)
                    
                case .inside:
                    // Mache Task zu Sub-Task des Target-Tasks
                    try await taskRepository.addSubTask(to: targetTaskId, task: droppedTask)
                    
                case .below:
                    // Verschiebe Task unter den Target-Task
                    let targetOrder = (targetTask.order ?? 0) + 1
                    try await taskRepository.moveTask(taskId: droppedTaskId, newParentId: targetTask.parentTaskId, newOrder: targetOrder)
                }
                
                print("✅ HeuteView: Task '\(droppedTask.title)' verschoben")
            } catch {
                print("⚠️ HeuteView: Fehler beim Verschieben: \(error)")
            }
        }
    }
}

struct TodayTaskCard: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main card content - not clickable
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .top, spacing: 0) {
                    // Productivity green left border for completed tasks
                    if task.completed {
                        Rectangle()
                            .fill(PremiumTheme.Colors.productivityGreen)
                            .frame(width: 4)
                            .padding(.trailing, PremiumTheme.Spacing.md)
                    }
                    
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        // Task Title
                        Text(task.title)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Completed Badge - Productivity green with checkmark
                        if task.completed {
                            HStack(spacing: PremiumTheme.Spacing.xs) {
                                ZStack {
                                    Circle()
                                        .fill(PremiumTheme.Colors.productivityGreen)
                                        .frame(width: 16, height: 16)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("Erledigt")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(PremiumTheme.Colors.productivityGreen)
                            }
                        }
                    
                    // Time Badge (if has time slot)
                    if let start = task.scheduledStartTime, let end = task.scheduledEndTime {
                        Text("\(start) - \(end)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                    
                    // Date (if scheduled)
                    if let scheduledDate = task.scheduledDate, let date = dateFromString(scheduledDate) {
                        Text(formatDate(date))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                    
                    // Notes (if available)
                    if let notes = task.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .padding(.top, PremiumTheme.Spacing.xs)
                    }
                    
                    // Category/Duration (if available)
                    if let category = task.category {
                        Text(category.rawValue.uppercased())
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .tracking(0.5)
                    }
                }
            }
            
            // Three dots menu - Top right corner (vertical)
            Menu {
                if task.completed {
                    Button(action: onToggle) {
                        Label("Als unerledigt markieren", systemImage: "arrow.uturn.backward")
                    }
                } else {
                    Button(action: onToggle) {
                        Label("Als erledigt markieren", systemImage: "checkmark")
                    }
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Löschen", systemImage: "trash")
                }
            } label: {
                VStack(spacing: 3) {
                    Circle()
                        .fill(PremiumTheme.Colors.textMuted)
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(PremiumTheme.Colors.textMuted)
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(PremiumTheme.Colors.textMuted)
                        .frame(width: 4, height: 4)
                }
                .padding(8)
            }
            .padding(.top, PremiumTheme.Spacing.md)
            .padding(.trailing, PremiumTheme.Spacing.md)
        }
        .padding(PremiumTheme.Spacing.xl)
            
            // Separator line before button
            if !task.completed {
                Divider()
                    .background(PremiumTheme.Colors.borderDefault)
                    .padding(.horizontal, PremiumTheme.Spacing.xl)
            }
            
            // Complete Button - Blue bar for pending tasks
            if !task.completed {
                Button(action: onToggle) {
                    HStack {
                        Spacer()
                        
                        HStack(spacing: PremiumTheme.Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                            
                            Text("Als erledigt markieren")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, PremiumTheme.Spacing.md)
                    .background(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        PremiumTheme.Colors.pendingBlue.opacity(0.15),
                                        PremiumTheme.Colors.pendingBlue.opacity(0.08)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                .fill(PremiumTheme.Colors.backgroundCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 0.5)
        )
    }
}

struct NewTaskSheet: View {
    @Binding var taskText: String
    @Binding var selectedDate: Date
    @Binding var repeatPattern: RepeatPattern?
    @Binding var repeatWeekdays: RepeatWeekdays?
    let initialStartTime: String?
    let initialEndTime: String?
    let initialNotes: String?
    let onSave: (String?, String?, Date, RepeatPattern?, RepeatWeekdays?, String?, String?) -> Void // startTime, endTime, date, repeatPattern, repeatWeekdays, notes, blockListId
    let onCancel: () -> Void
    @State private var hasTimeSlot = false
    @State private var hasDate = false
    @State private var isRepeating = false
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600) // +1 hour
    @State private var showingRepeatMenu = false
    @State private var tempRepeatPattern: RepeatPattern? = nil
    @State private var tempRepeatWeekdays = RepeatWeekdays()
    @State private var taskNotes: String = ""
    @State private var selectedBlockListId: String? = nil
    @StateObject private var blockListRepository = BlockListRepository.shared
    @FocusState private var isFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    // Helper to parse time string (HH:mm) to Date
    private func parseTime(_ timeString: String?) -> Date? {
        guard let timeString = timeString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let calendar = Calendar.current
        
        // Parse time string to get hour and minute
        if let time = formatter.date(from: timeString) {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: Date())
        }
        return nil
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: PremiumTheme.Spacing.lg) {
                    // Task Text
                    TextField("Aufgabe eingeben...", text: $taskText, axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                .fill(PremiumTheme.Colors.backgroundCard)
                        )
                        .focused($isFocused)
                        .onAppear {
                            isFocused = true
                            
                            // Set initial values from voice recognition
                            if let initialStart = initialStartTime, let parsedStart = parseTime(initialStart) {
                                startTime = parsedStart
                                hasTimeSlot = true
                            }
                            if let initialEnd = initialEndTime, let parsedEnd = parseTime(initialEnd) {
                                endTime = parsedEnd
                                hasTimeSlot = true
                            }
                            if let notes = initialNotes, !notes.isEmpty {
                                taskNotes = notes
                            }
                            // Check if date is not today (then enable date toggle)
                            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                                hasDate = true
                            }
                            
                            // Set isRepeating based on initial repeatPattern
                            if repeatPattern != nil {
                                isRepeating = true
                                tempRepeatPattern = repeatPattern
                            }
                        }
                        .onChange(of: repeatPattern) { newPattern in
                            isRepeating = newPattern != nil
                            tempRepeatPattern = newPattern
                        }
                    
                    // Time Slot Toggle (FIRST - above date)
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                        Toggle("Zeitspanne hinzufügen", isOn: $hasTimeSlot)
                            .font(.system(size: 16))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .tint(PremiumTheme.Colors.ralphLaurenBlue)
                        
                        if hasTimeSlot {
                            HStack(spacing: PremiumTheme.Spacing.md) {
                                // Start Time
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                    Text("Von")
                                        .font(.system(size: 12))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(PremiumTheme.Colors.ralphLaurenBlue)
                                }
                                
                                // End Time
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                    Text("Bis")
                                        .font(.system(size: 12))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(PremiumTheme.Colors.ralphLaurenBlue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                    
                    // Date Selection (BELOW time slot)
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                        Toggle("Datum hinzufügen", isOn: $hasDate)
                            .font(.system(size: 16))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .tint(PremiumTheme.Colors.ralphLaurenBlue)
                        
                        if hasDate {
                            DatePicker("Datum", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(PremiumTheme.Colors.ralphLaurenBlue)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                    
                    // Notes Field
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                        Text("Notiz")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                        
                        TextField("Notiz zur Aufgabe...", text: $taskNotes, axis: .vertical)
                            .font(.system(size: 14))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .padding(8)
                            .frame(minHeight: 60)
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                    .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                            )
                            .focused($isNotesFocused)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                    
                    // BlockList Selection
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                        Text("Blockliste")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                        
                        Menu {
                            // Standard-Blockliste (nil)
                            Button(action: {
                                selectedBlockListId = nil
                            }) {
                                HStack {
                                    if selectedBlockListId == nil {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Standard (Klassik)")
                                }
                            }
                            
                            Divider()
                            
                            // Alle Blocklisten
                            ForEach(blockListRepository.blockLists) { blockList in
                                Button(action: {
                                    selectedBlockListId = blockList.id
                                }) {
                                    HStack {
                                        if selectedBlockListId == blockList.id {
                                            Image(systemName: "checkmark")
                                        }
                                        Text(blockList.name)
                                        if blockList.isDefault {
                                            Text("(Standard)")
                                                .font(.system(size: 12))
                                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 16))
                                Text(selectedBlockListId == nil ? "Standard (Klassik)" : (blockListRepository.getBlockList(id: selectedBlockListId ?? "")?.name ?? "Standard"))
                                    .font(.system(size: 16))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(PremiumTheme.Colors.backgroundCard)
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                    
                    // Repeat Button
                    Button(action: { showingRepeatMenu = true }) {
                        HStack {
                            Image(systemName: isRepeating ? "repeat.circle.fill" : "repeat.circle")
                                .font(.system(size: 18))
                            Text("Wiederkehrend")
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            if isRepeating {
                                if let pattern = repeatPattern {
                                    Text(pattern == .weekdays ? (repeatWeekdays?.displayText ?? "") : pattern.rawValue.capitalized)
                                        .font(.system(size: 14))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                }
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                        }
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                .fill(PremiumTheme.Colors.backgroundCard)
                        )
                    }
                }
                .padding()
            }
            .background(PremiumTheme.Colors.backgroundMain)
            .navigationTitle("Neue Aufgabe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen", action: onCancel)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        let start = hasTimeSlot ? timeFormatter.string(from: startTime) : nil
                        let end = hasTimeSlot ? timeFormatter.string(from: endTime) : nil
                        let notes = taskNotes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : taskNotes.trimmingCharacters(in: .whitespaces)
                        onSave(start, end, selectedDate, repeatPattern, repeatWeekdays, notes, selectedBlockListId)
                    }
                    .foregroundColor(PremiumTheme.Colors.ralphLaurenBlue)
                    .fontWeight(.semibold)
                    .disabled(taskText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingRepeatMenu) {
                RepeatMenuSheet(
                    repeatPattern: $repeatPattern,
                    repeatWeekdays: $repeatWeekdays,
                    isRepeating: $isRepeating,
                    onSave: {
                        showingRepeatMenu = false
                    },
                    onCancel: {
                        showingRepeatMenu = false
                    }
                )
            }
        }
    }
}

struct RepeatMenuSheet: View {
    @Binding var repeatPattern: RepeatPattern?
    @Binding var repeatWeekdays: RepeatWeekdays?
    @Binding var isRepeating: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    @State private var tempPattern: RepeatPattern? = nil
    @State private var tempWeekdays = RepeatWeekdays()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.lg) {
                    // Repeat Options
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Wiederholung")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        // Daily
                        Button(action: {
                            tempPattern = .daily
                            tempWeekdays = RepeatWeekdays()
                        }) {
                            HStack {
                                Image(systemName: tempPattern == .daily ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tempPattern == .daily ? PremiumTheme.Colors.ralphLaurenBlue : PremiumTheme.Colors.textMuted)
                                Text("Täglich")
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(tempPattern == .daily ? PremiumTheme.Colors.ralphLaurenBlue.opacity(0.1) : PremiumTheme.Colors.backgroundCard)
                            )
                        }
                        
                        // Weekly
                        Button(action: {
                            tempPattern = .weekly
                            tempWeekdays = RepeatWeekdays()
                        }) {
                            HStack {
                                Image(systemName: tempPattern == .weekly ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tempPattern == .weekly ? PremiumTheme.Colors.ralphLaurenBlue : PremiumTheme.Colors.textMuted)
                                Text("Wöchentlich")
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(tempPattern == .weekly ? PremiumTheme.Colors.ralphLaurenBlue.opacity(0.1) : PremiumTheme.Colors.backgroundCard)
                            )
                        }
                        
                        // Monthly
                        Button(action: {
                            tempPattern = .monthly
                            tempWeekdays = RepeatWeekdays()
                        }) {
                            HStack {
                                Image(systemName: tempPattern == .monthly ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tempPattern == .monthly ? PremiumTheme.Colors.ralphLaurenBlue : PremiumTheme.Colors.textMuted)
                                Text("Monatlich")
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(tempPattern == .monthly ? PremiumTheme.Colors.ralphLaurenBlue.opacity(0.1) : PremiumTheme.Colors.backgroundCard)
                            )
                        }
                        
                        // Specific Weekdays
                        Button(action: {
                            tempPattern = .weekdays
                        }) {
                            HStack {
                                Image(systemName: tempPattern == .weekdays ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(tempPattern == .weekdays ? PremiumTheme.Colors.ralphLaurenBlue : PremiumTheme.Colors.textMuted)
                                Text("Bestimmte Wochentage")
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(tempPattern == .weekdays ? PremiumTheme.Colors.ralphLaurenBlue.opacity(0.1) : PremiumTheme.Colors.backgroundCard)
                            )
                        }
                        
                        // Weekday Selection (if weekdays selected)
                        if tempPattern == .weekdays {
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                Text("Wochentage auswählen")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                                    .padding(.top, PremiumTheme.Spacing.sm)
                                
                                VStack(spacing: PremiumTheme.Spacing.xs) {
                                    WeekdayToggleRow(day: "Montag", isOn: $tempWeekdays.monday)
                                    WeekdayToggleRow(day: "Dienstag", isOn: $tempWeekdays.tuesday)
                                    WeekdayToggleRow(day: "Mittwoch", isOn: $tempWeekdays.wednesday)
                                    WeekdayToggleRow(day: "Donnerstag", isOn: $tempWeekdays.thursday)
                                    WeekdayToggleRow(day: "Freitag", isOn: $tempWeekdays.friday)
                                    WeekdayToggleRow(day: "Samstag", isOn: $tempWeekdays.saturday)
                                    WeekdayToggleRow(day: "Sonntag", isOn: $tempWeekdays.sunday)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                                )
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                }
                .padding()
            }
            .background(PremiumTheme.Colors.backgroundMain)
            .navigationTitle("Wiederholung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen", action: onCancel)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        if tempPattern != nil {
                            repeatPattern = tempPattern
                            if tempPattern == .weekdays {
                                repeatWeekdays = tempWeekdays
                            } else {
                                repeatWeekdays = nil
                            }
                            isRepeating = true
                        } else {
                            repeatPattern = nil
                            repeatWeekdays = nil
                            isRepeating = false
                        }
                        onSave()
                    }
                    .foregroundColor(PremiumTheme.Colors.ralphLaurenBlue)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                tempPattern = repeatPattern
                tempWeekdays = repeatWeekdays ?? RepeatWeekdays()
            }
        }
    }
}

struct WeekdayToggleRow: View {
    let day: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(day, isOn: $isOn)
            .font(.system(size: 16))
            .foregroundColor(PremiumTheme.Colors.textPrimary)
            .tint(PremiumTheme.Colors.ralphLaurenBlue)
    }
}

