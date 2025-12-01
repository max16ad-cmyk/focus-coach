//
//  PlanungView.swift
//  FocusCoach
//
//  Tab 2: PLANUNG - Week overview and task planning
//

import SwiftUI

struct PlanungView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @StateObject private var blockingMonitor = TaskBlockingMonitor.shared
    @StateObject private var taskRepository = TaskRepository.shared
    @State private var selectedDate: Date = Date()
    @State private var showCalendar = false
    @State private var currentMonth: Date = Date()
    @State private var showingNewTask = false
    @State private var newTaskText = ""
    @State private var newTaskStartTime: String?
    @State private var newTaskEndTime: String?
    @State private var newTaskDate: Date = Date()
    @State private var newTaskRepeatPattern: RepeatPattern? = nil
    @State private var newTaskRepeatWeekdays: RepeatWeekdays? = nil
    @State private var newTaskNotes: String = ""
    @State private var newTaskBlockListId: String? = nil
    
    // Computed properties using TaskRepository
    private var tasks: [Task] {
        taskRepository.getTasksForWeek(containing: selectedDate)
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
    
    private var tasksForSelectedDate: [Task] {
        var dateTasks = tasks.filter { $0.scheduledDate == selectedDateString }
        
        // If selected date is today, also include tasks without date
        if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
            let tasksWithoutDate = tasks.filter { $0.scheduledDate == nil }
            dateTasks.append(contentsOf: tasksWithoutDate)
        }
        
        // Sort: pending first, then completed, then by creation time
        return dateTasks.sorted { task1, task2 in
            // First: pending before completed
            if task1.completed != task2.completed {
                return !task1.completed && task2.completed
            }
            // Then: by time if both have time
            if task1.hasTimeSlot && task2.hasTimeSlot {
                guard let time1 = task1.scheduledStartTime,
                      let time2 = task2.scheduledStartTime else { return false }
                return time1 < time2
            }
            // Then: by creation time
            let time1 = task1.createdAt ?? 0
            let time2 = task2.createdAt ?? 0
            return time1 > time2 // Newer first
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
                                    .rotationEffect(.degrees(showCalendar ? 0 : 0))
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showCalendar)
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
                    .padding(.top, PremiumTheme.Spacing.md)
                    
                    // Expanded Calendar View
                    if showCalendar {
                        ExpandedCalendarView(
                            selectedDate: $selectedDate,
                            currentMonth: $currentMonth
                        )
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                        .padding(.top, PremiumTheme.Spacing.md)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95))
                        ))
                    }
                    
                    // Week Bar (only visible when calendar is collapsed)
                    if !showCalendar {
                        WeekBar(selectedDate: $selectedDate, weekDates: weekDates)
                            .padding(.top, PremiumTheme.Spacing.md)
                            .gesture(
                                DragGesture(minimumDistance: 5)
                                    .onChanged { value in
                                        // Optional: Add haptic feedback during drag
                                    }
                                    .onEnded { value in
                                        let threshold: CGFloat = 20 // Niedrigere Schwelle für empfindlichere Erkennung
                                        let velocity = value.predictedEndTranslation.width - value.translation.width
                                        
                                        // Berechne Anzahl der Tage basierend auf Swipe-Distanz
                                        let swipeDistance = abs(value.translation.width)
                                        let daysToMove = max(1, Int(swipeDistance / 50)) // ~50px pro Tag
                                        
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)) {
                                            if value.translation.width > threshold || velocity > 100 {
                                                // Swipe right - vorherige Tage
                                                selectedDate = Calendar.current.date(byAdding: .day, value: -daysToMove, to: selectedDate) ?? selectedDate
                                            } else if value.translation.width < -threshold || velocity < -100 {
                                                // Swipe left - nächste Tage
                                                selectedDate = Calendar.current.date(byAdding: .day, value: daysToMove, to: selectedDate) ?? selectedDate
                                            }
                                        }
                                    }
                            )
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
                            // Tasks with time slot (sorted by time)
                            if !tasksWithTime.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    HStack(spacing: PremiumTheme.Spacing.xs) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 14))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                        Text("Zeitlich geplant")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                    }
                                    .padding(.bottom, PremiumTheme.Spacing.xs)
                                    
                                    ForEach(tasksWithTime) { task in
                                        PlannedTaskRow(
                                            task: task,
                                            showTime: true,
                                            onToggle: {
                                                toggleTask(task)
                                            }
                                        )
                                    }
                                }
                            }
                            
                            // Tasks without time slot
                            if !tasksWithoutTime.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    HStack(spacing: PremiumTheme.Spacing.xs) {
                                        Image(systemName: "list.bullet")
                                            .font(.system(size: 14))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                        Text("Ohne Zeit")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                    }
                                    .padding(.top, tasksWithTime.isEmpty ? 0 : PremiumTheme.Spacing.md)
                                    .padding(.bottom, PremiumTheme.Spacing.xs)
                                    
                                    ForEach(tasksWithoutTime) { task in
                                        PlannedTaskRow(
                                            task: task,
                                            showTime: false,
                                            onToggle: {
                                                toggleTask(task)
                                            }
                                        )
                                    }
                                }
                            }
                            
                            // Completed tasks section
                            if !completedTasks.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    HStack(spacing: PremiumTheme.Spacing.xs) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(PremiumTheme.Colors.productivityGreen)
                                        Text("Erledigt")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(PremiumTheme.Colors.productivityGreen)
                                    }
                                    .padding(.top, (tasksWithTime.isEmpty && tasksWithoutTime.isEmpty) ? 0 : PremiumTheme.Spacing.lg)
                                    .padding(.bottom, PremiumTheme.Spacing.xs)
                                    
                                    ForEach(completedTasks) { task in
                                        PlannedTaskRow(
                                            task: task,
                                            showTime: task.hasTimeSlot,
                                            onToggle: {
                                                toggleTask(task)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    
                    // Unscheduled tasks (only show if not today, as they appear in today's list)
                    if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                        let unscheduledTasks = tasks.filter { $0.scheduledDate == nil && !$0.completed }
                        if !unscheduledTasks.isEmpty {
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                                Text("Ohne Datum")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    .padding(.top, PremiumTheme.Spacing.lg)
                                
                                VStack(spacing: PremiumTheme.Spacing.md) {
                                    ForEach(unscheduledTasks) { task in
                                        PlannedTaskRow(
                                            task: task,
                                            showTime: task.hasTimeSlot,
                                            onToggle: {
                                                toggleTask(task)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                        }
                    }
                    
                    // Bottom padding for FAB
                    Spacer()
                        .frame(height: 100)
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
                    Button(action: {
                        newTaskDate = selectedDate
                        showingNewTask = true
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
        .onAppear {
            blockingMonitor.checkActiveTasks() // Update blocking on appear
            // Tasks werden automatisch über TaskRepository Real-time Sync geladen
        }
        .onChange(of: selectedDate) { newDate in
            // Update currentMonth when date changes significantly
            let calendar = Calendar.current
            if !calendar.isDate(newDate, equalTo: currentMonth, toGranularity: .month) {
                currentMonth = newDate
            }
            // Tasks werden automatisch über TaskRepository Real-time Sync geladen
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
                    newTaskDate = selectedDate
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
                    newTaskDate = selectedDate
                    newTaskRepeatPattern = nil
                    newTaskRepeatWeekdays = nil
                    newTaskNotes = ""
                }
            )
        }
    }
    
    private func addTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let scheduledDateString = dateFormatter.string(from: newTaskDate)
        
        // If no time slot and date is today, don't set scheduledDate
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: currentMonth)
    }
    
    private func navigateMonth(_ direction: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: direction, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

struct WeekBar: View {
    @Binding var selectedDate: Date
    let weekDates: [Date]
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    private let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                Button(action: { selectedDate = date }) {
                    VStack(spacing: PremiumTheme.Spacing.xs) {
                        Text(dayFormatter.string(from: date))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isSelected(date) ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textSecondary)
                        
                        Text(dayNumberFormatter.string(from: date))
                            .font(.system(size: 18, weight: isSelected(date) ? .semibold : .regular))
                            .foregroundColor(isSelected(date) ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PremiumTheme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                            .fill(isSelected(date) ? PremiumTheme.Colors.pendingBlue.opacity(0.1) : Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, PremiumTheme.Spacing.md)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

struct PlannedTaskRow: View {
    let task: Task
    let showTime: Bool
    let onToggle: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                // Header Row
                HStack(spacing: PremiumTheme.Spacing.md) {
                    // Circular checkbox - clickable
                    Button(action: onToggle) {
                        ZStack {
                            Circle()
                                .stroke(task.completed ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.pendingBlue, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if task.completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(PremiumTheme.Colors.productivityGreen)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Task Title
                    Text(task.title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(task.completed ? PremiumTheme.Colors.textSecondary : PremiumTheme.Colors.textPrimary)
                        .strikethrough(task.completed)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            
            // Time badge (if has time slot)
            if showTime, let start = task.scheduledStartTime, let end = task.scheduledEndTime {
                HStack(spacing: PremiumTheme.Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(task.completed ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.pendingBlue)
                    Text("\(start) - \(end)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(task.completed ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.pendingBlue)
                }
                .padding(.horizontal, PremiumTheme.Spacing.sm)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill((task.completed ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.pendingBlue).opacity(0.15))
                )
            }
            
            // Repeat pattern
            if let repeatPattern = task.repeatPattern {
                HStack(spacing: PremiumTheme.Spacing.xs) {
                    Image(systemName: "repeat")
                        .font(.system(size: 12))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                    Text(repeatPattern.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
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
        .padding(.top, PremiumTheme.Spacing.xs)
        .padding(.trailing, PremiumTheme.Spacing.xs)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
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

