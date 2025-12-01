//
//  PremiumWelcomeView.swift
//  FocusCoach
//
//  EQUINOX+ Style Welcome Screen
//

import SwiftUI

struct PremiumWelcomeView: View {
    let userName: String
    let currentDate: String
    let tasks: [Task]
    let onCreatePlan: () -> Void
    let onAddTask: (() -> Void)?
    
    var hasTasks: Bool {
        !tasks.isEmpty
    }
    
    init(userName: String, currentDate: String, tasks: [Task], onCreatePlan: @escaping () -> Void, onAddTask: (() -> Void)? = nil) {
        self.userName = userName
        self.currentDate = currentDate
        self.tasks = tasks
        self.onCreatePlan = onCreatePlan
        self.onAddTask = onAddTask
    }
    
    var body: some View {
        ZStack {
            // Pure black background like EQUINOX+
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer()
                        .frame(height: PremiumTheme.Spacing.lg)
                    
                    // Welcome message - EQUINOX+ style
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Welcome \(userName)!")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                        
                        // Large serif headline like EQUINOX+
                        Text("Realize Your Potential")
                            .font(PremiumTheme.Typography.headlineXL)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .lineLimit(2)
                        
                        Text("Share some background on your goals and interests to help customize your productivity experience with recommendations and content.")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, PremiumTheme.Spacing.sm)
                        
                        // Time indicator
                        HStack(spacing: PremiumTheme.Spacing.xs) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                            Text("Total time: less than 1 minute")
                                .font(PremiumTheme.Typography.bodyXS)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                        }
                        .padding(.top, PremiumTheme.Spacing.md)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.xxl)
                    
                    // Progress indicators if tasks exist
                    if hasTasks {
                        VStack(spacing: PremiumTheme.Spacing.md) {
                            // Check-in Goal
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                Text("CHECK-IN GOAL")
                                    .font(PremiumTheme.Typography.label)
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                    .tracking(PremiumTheme.Typography.labelTracking)
                                
                                HStack {
                                    Text("\(tasks.filter { $0.completed }.count)/\(tasks.count) Check-ins")
                                        .font(PremiumTheme.Typography.bodySM)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    Spacer()
                                }
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(PremiumTheme.Colors.backgroundCard)
                                            .frame(height: 4)
                                        
                                        Rectangle()
                                            .fill(PremiumTheme.Colors.ralphLaurenBlue)
                                            .frame(
                                                width: geometry.size.width * CGFloat(tasks.filter { $0.completed }.count) / CGFloat(max(tasks.count, 1)),
                                                height: 4
                                            )
                                    }
                                }
                                .frame(height: 4)
                            }
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                            
                            // YOU section
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                Text("YOU")
                                    .font(PremiumTheme.Typography.label)
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                    .tracking(PremiumTheme.Typography.labelTracking)
                                
                                HStack {
                                    Text("\(tasks.filter { $0.completed }.count)/\(tasks.count)")
                                        .font(PremiumTheme.Typography.bodySM)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    Spacer()
                                }
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(PremiumTheme.Colors.backgroundCard)
                                            .frame(height: 4)
                                        
                                        Rectangle()
                                            .fill(PremiumTheme.Colors.accentGreen)
                                            .frame(
                                                width: geometry.size.width * CGFloat(tasks.filter { $0.completed }.count) / CGFloat(max(tasks.count, 1)),
                                                height: 4
                                            )
                                    }
                                }
                                .frame(height: 4)
                            }
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                        }
                        .padding(.bottom, PremiumTheme.Spacing.xl)
                    }
                    
                    // Main headline - EQUINOX+ style
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("What will you accomplish today?")
                            .font(PremiumTheme.Typography.headlineLG)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.lg)
                    
                    // Action cards or create plan button
                    if hasTasks {
                        // Show task cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: PremiumTheme.Spacing.md) {
                                ForEach(tasks.prefix(2)) { task in
                                    WelcomeTaskCard(task: task)
                                }
                            }
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                        }
                        .padding(.bottom, PremiumTheme.Spacing.xl)
                    } else {
                        // Create Plan Button - EQUINOX+ style
                        VStack(spacing: PremiumTheme.Spacing.md) {
                            EquinoxButton(
                                title: "Let's go",
                                icon: nil,
                                style: .primary,
                                action: onCreatePlan
                            )
                            
                            EquinoxButton(
                                title: "Skip for now",
                                icon: nil,
                                style: .secondary,
                                action: onCreatePlan
                            )
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                        .padding(.bottom, PremiumTheme.Spacing.xl)
                    }
                    
                    // Privacy policy link
                    Button(action: {}) {
                        Text("Privacy Policy")
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .underline()
                    }
                    .padding(.bottom, PremiumTheme.Spacing.xxl)
                }
            }
        }
    }
}

// MARK: - Welcome Task Card (EQUINOX+ Style)

struct WelcomeTaskCard: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
            // Image placeholder
            ZStack {
                Rectangle()
                    .fill(PremiumTheme.Colors.backgroundCard)
                    .aspectRatio(16/9, contentMode: .fit)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(PremiumTheme.Colors.ralphLaurenBlue)
            }
            .cornerRadius(PremiumTheme.CornerRadius.md)
            
            // ON-DEMAND tag
            HStack {
                HighlightTag(text: "ON-DEMAND")
                Spacer()
            }
            
            // Task info
            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                Text(task.title)
                    .font(PremiumTheme.Typography.headlineSM)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: PremiumTheme.Spacing.sm) {
                    if let category = task.category {
                        Text(category.rawValue)
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                    }
                    
                    if let duration = task.duration {
                        Text("• \(duration) mins")
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                    }
                }
            }
        }
        .frame(width: 280)
        .padding(PremiumTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                .fill(PremiumTheme.Colors.backgroundCard)
        )
    }
}
