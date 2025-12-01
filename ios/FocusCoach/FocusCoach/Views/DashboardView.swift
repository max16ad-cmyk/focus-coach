//
//  DashboardView.swift
//  FocusCoach
//
//  Main Dashboard - Navigation & Mode Management
//

import SwiftUI

enum DashboardViewMode: String {
    case overview = "overview"
    case createPlan = "create-plan"
    case activeDay = "active-day"
    case verification = "verification"
    case freedom = "freedom"
    case night = "night"
}

struct DashboardView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    private let modeManager = ModeManager()
    @State private var currentView: DashboardViewMode = .overview
    @State private var showSettings = false
    @State private var dayPlan: DayPlan?
    @State private var settings: UserSettings = .default
    @State private var analyzedTasks: [AnalyzedTask] = []
    @State private var verifyingTask: Task?
    
    init() {
        AppLogger.shared.traceEnter("DashboardView.init")
        defer { AppLogger.shared.traceExit("DashboardView.init") }
        AppLogger.shared.info("📊 DashboardView.init() - Starting initialization")
        AppLogger.shared.logStackTrace(message: "DashboardView init stack trace")
    }
    
    var body: some View {
        let _ = AppLogger.shared.info("📊 DashboardView body called")
        
        return ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar - EQUINOX+ Style
                EquinoxTopBar(
                    currentView: currentView,
                    onViewChange: { (newView: DashboardViewMode) in
                        let autoMode = modeManager.getCurrentMode(
                            settings: settings,
                            dayPlan: dayPlan,
                            userOverride: nil
                        )
                        if modeManager.canNavigateTo(newView, autoMode: autoMode, settings: settings) {
                            currentView = newView
                        }
                    },
                    dayPlan: dayPlan,
                    onSettingsTap: { showSettings = true },
                    userName: firebaseService.currentUser?.name ?? "User"
                )
                
                // Main Content
                ScrollView {
                    VStack(spacing: 0) {
                        switch currentView {
                        case .overview:
                            PremiumWelcomeView(
                                userName: firebaseService.currentUser?.name ?? "User",
                                currentDate: getCurrentDate(),
                                tasks: dayPlan?.tasks ?? [],
                                onCreatePlan: { currentView = .createPlan },
                                onAddTask: dayPlan != nil ? { currentView = .activeDay } : nil
                            )
                        case .createPlan:
                            PlanCreationView(
                                onPlanCreated: { plan in
                                    dayPlan = plan
                                    _Concurrency.Task {
                                        try? await firebaseService.saveDayPlan(plan)
                                        await MainActor.run {
                                            currentView = .overview
                                        }
                                    }
                                },
                                onCancel: { currentView = .overview }
                            )
                        case .activeDay:
                            if let plan = dayPlan {
                                ActiveDayView(
                                    dayPlan: plan,
                                    onTaskComplete: { taskId in
                                        _Concurrency.Task {
                                            let updatedTasks = plan.tasks.map { task in
                                                if task.id == taskId {
                                                    var updated = task
                                                    updated.completed = true
                                                    updated.status = .completed
                                                    return updated
                                                }
                                                return task
                                            }
                                            let updatedPlan = DayPlan(
                                                id: plan.id,
                                                userId: plan.userId,
                                                date: plan.date,
                                                tasks: updatedTasks,
                                                createdAt: plan.createdAt,
                                                confirmed: plan.confirmed
                                            )
                                            try? await firebaseService.saveDayPlan(updatedPlan)
                                            await MainActor.run {
                                                dayPlan = updatedPlan
                                            }
                                        }
                                    },
                                    onUploadProof: { taskId in
                                        if let task = plan.tasks.first(where: { $0.id == taskId }) {
                                            verifyingTask = task
                                            currentView = .verification
                                        }
                                    }
                                )
                            } else {
                                Text("Kein Plan vorhanden")
                                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                                    .padding()
                            }
                        case .verification:
                            if let task = verifyingTask {
                                VerificationView(
                                    task: task,
                                    onVerified: { verified in
                                        if verified, let plan = dayPlan {
                                            _Concurrency.Task {
                                                let updatedTasks = plan.tasks.map { t in
                                                    if t.id == task.id {
                                                        var updated = t
                                                        updated.verified = true
                                                        updated.completed = true
                                                        updated.status = .completed
                                                        return updated
                                                    }
                                                    return t
                                                }
                                                let updatedPlan = DayPlan(
                                                    id: plan.id,
                                                    userId: plan.userId,
                                                    date: plan.date,
                                                    tasks: updatedTasks,
                                                    createdAt: plan.createdAt,
                                                    confirmed: plan.confirmed
                                                )
                                                try? await firebaseService.saveDayPlan(updatedPlan)
                                                await MainActor.run {
                                                    dayPlan = updatedPlan
                                                    verifyingTask = nil
                                                    currentView = .activeDay
                                                }
                                            }
                                        } else {
                                            verifyingTask = nil
                                            currentView = .activeDay
                                        }
                                    },
                                    onCancel: {
                                        verifyingTask = nil
                                        currentView = .activeDay
                                    }
                                )
                            } else {
                                Text("Keine Aufgabe zum Verifizieren")
                                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                                    .padding()
                            }
                        case .freedom:
                            if let plan = dayPlan {
                                FreedomModeView(completedTasks: plan.tasks.filter { $0.completed })
                            } else {
                                Text("Kein Plan vorhanden")
                                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                                    .padding()
                            }
                        case .night:
                            NightModeView()
                        }
                    }
                }
            }
        }
        .onAppear {
            AppLogger.shared.info("📊 DashboardView appeared, currentView=\(currentView), isAuthenticated=\(firebaseService.isAuthenticated)")
            loadData()
            updateMode()
        }
        .onChange(of: dayPlan?.id) { _ in updateMode() }
        .onChange(of: settings.nightModeEnabled) { _ in updateMode() }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: $settings)
        }
        .safeAreaInset(edge: .bottom) {
            // Bottom Navigation - EQUINOX+ Style
            EquinoxBottomNav(currentView: currentView, onViewChange: { newView in
                let autoMode = modeManager.getCurrentMode(
                    settings: settings,
                    dayPlan: dayPlan,
                    userOverride: nil
                )
                if modeManager.canNavigateTo(newView, autoMode: autoMode, settings: settings) {
                    currentView = newView
                }
            })
        }
    }
    
    private func loadData() {
        // Load day plan and settings from Firebase
        _Concurrency.Task {
            let today = getCurrentDate()
            if let plan = try? await firebaseService.getDayPlan(date: today) {
                await MainActor.run {
                    dayPlan = plan
                }
            }
            if let userSettings = try? await firebaseService.getSettings() {
                await MainActor.run {
                    settings = userSettings
                }
            }
        }
    }
    
    private func updateMode() {
        let mode = modeManager.getCurrentMode(
            settings: settings,
            dayPlan: dayPlan,
            userOverride: currentView
        )
        currentView = mode
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - EQUINOX+ Top Bar

struct EquinoxTopBar: View {
    let currentView: DashboardViewMode
    let onViewChange: (DashboardViewMode) -> Void
    let dayPlan: DayPlan?
    let onSettingsTap: () -> Void
    let userName: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: PremiumTheme.Spacing.md) {
                // Highlight tag (like EQUINOX+)
                HighlightTag(text: "Highlight")
                
                Spacer()
                
                // User avatar/initials
                Circle()
                    .fill(PremiumTheme.Colors.backgroundCard)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(userName.prefix(2).uppercased())
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                    )
                
                // Search icon
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                
                // Bookmark icon
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                
                // Classes/Plan button
                Button(action: {
                    if dayPlan == nil {
                        onViewChange(.createPlan)
                    } else {
                        onViewChange(.activeDay)
                    }
                }) {
                    Text(dayPlan == nil ? "Plan" : "Tasks")
                        .font(PremiumTheme.Typography.bodySM)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                        .padding(.horizontal, PremiumTheme.Spacing.sm)
                        .padding(.vertical, PremiumTheme.Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                .fill(PremiumTheme.Colors.backgroundCard)
                        )
                }
            }
            .padding(.horizontal, PremiumTheme.Spacing.lg)
            .padding(.vertical, PremiumTheme.Spacing.md)
        }
        .background(PremiumTheme.Colors.backgroundMain)
    }
}

// MARK: - EQUINOX+ Bottom Navigation

struct EquinoxBottomNav: View {
    let currentView: DashboardViewMode
    let onViewChange: (DashboardViewMode) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            NavButton(
                icon: "house.fill",
                label: "Home",
                isActive: currentView == .overview,
                action: { onViewChange(.overview) }
            )
            
            // Explore
            NavButton(
                icon: "square.grid.2x2",
                label: "Explore",
                isActive: currentView == .createPlan,
                action: { onViewChange(.createPlan) }
            )
            
            // Activity
            NavButton(
                icon: "chart.bar.fill",
                label: "Activity",
                isActive: currentView == .activeDay,
                action: { onViewChange(.activeDay) }
            )
            
            // More
            NavButton(
                icon: "ellipsis",
                label: "More",
                isActive: false,
                action: {}
            )
        }
        .frame(height: 60)
        .background(PremiumTheme.Colors.backgroundCard)
    }
}

struct NavButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textSecondary)
                
                Text(label)
                    .font(PremiumTheme.Typography.bodyXS)
                    .foregroundColor(isActive ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Dashboard Header (Legacy - kept for compatibility)

struct DashboardHeader: View {
    let currentView: DashboardViewMode
    let onViewChange: (DashboardViewMode) -> Void
    let dayPlan: DayPlan?
    let onSettingsTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar - Logo and Settings
            HStack(spacing: PremiumTheme.Spacing.md) {
                // Logo
                Text("Focus")
                    .font(PremiumTheme.Typography.headlineSM)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                + Text("Coach")
                    .font(PremiumTheme.Typography.headlineSM)
                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                
                Spacer()
                
                // Settings Button
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, PremiumTheme.Spacing.md)
            .padding(.vertical, PremiumTheme.Spacing.sm)
            
            // Navigation - Segmented Control for Mobile
            if dayPlan == nil {
                // No plan - Show Overview and Create Plan
                Picker("View", selection: Binding(
                    get: { currentView == .overview ? 0 : 1 },
                    set: { newValue in
                        onViewChange(newValue == 0 ? .overview : .createPlan)
                    }
                )) {
                    Text("Übersicht").tag(0)
                    Text("Plan erstellen").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, PremiumTheme.Spacing.md)
                .padding(.bottom, PremiumTheme.Spacing.sm)
            } else {
                // Has plan - Show Overview and Active Day
                Picker("View", selection: Binding(
                    get: { currentView == .overview ? 0 : 1 },
                    set: { newValue in
                        onViewChange(newValue == 0 ? .overview : .activeDay)
                    }
                )) {
                    Text("Übersicht").tag(0)
                    Text("Aktueller Tag").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, PremiumTheme.Spacing.md)
                .padding(.bottom, PremiumTheme.Spacing.sm)
            }
            
            Divider()
                .background(PremiumTheme.Colors.textMuted.opacity(0.2))
        }
        .background(
            PremiumTheme.Colors.backgroundElevated
                .opacity(0.8)
                .blur(radius: 20)
        )
    }
}

// MARK: - Navigation Button Style

struct NavButtonStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PremiumTheme.Typography.bodySM)
            .foregroundColor(isActive ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textSecondary)
            .padding(.horizontal, PremiumTheme.Spacing.md)
            .padding(.vertical, PremiumTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? PremiumTheme.Colors.backgroundGlass : Color.clear)
            )
    }
}

// MARK: - Settings View (Placeholder)

struct SettingsView: View {
    @Binding var settings: UserSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Einstellungen")
                    .font(PremiumTheme.Typography.headlineMD)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                    .padding()
                
                Text("Coming soon...")
                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PremiumTheme.Colors.backgroundMain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

