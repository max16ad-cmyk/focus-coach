//
//  ActiveDayView.swift
//  FocusCoach
//
//  Active Day View - Current Task & Task List
//

import SwiftUI

struct ActiveDayView: View {
    let dayPlan: DayPlan
    let onTaskComplete: (String) -> Void
    let onUploadProof: (String) -> Void
    
    var currentTask: Task? {
        dayPlan.tasks.first { !$0.completed }
    }
    
    var completedCount: Int {
        dayPlan.tasks.filter { $0.completed }.count
    }
    
    var totalCount: Int {
        dayPlan.tasks.count
    }
    
    var progress: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: PremiumTheme.Spacing.xxl) {
                // Header
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                    Text("Dein Tag läuft")
                        .font(PremiumTheme.Typography.headlineMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    Text(getFormattedDateTime())
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                    
                    // Progress Card
                    HStack(spacing: PremiumTheme.Spacing.md) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                            Text("Fortschritt")
                                .font(PremiumTheme.Typography.label)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                            
                            Text("\(completedCount)/\(totalCount)")
                                .font(PremiumTheme.Typography.headlineMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            ProgressView(value: progress)
                                .tint(.green)
                            
                            Text("\(Int(progress * 100))% erledigt")
                                .font(PremiumTheme.Typography.bodySM)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                        }
                    }
                    .padding(PremiumTheme.Spacing.lg)
                    .glassmorphism()
                }
                .padding(.horizontal, PremiumTheme.Spacing.xl)
                .padding(.top, PremiumTheme.Spacing.xxl)
                
                // Current Task
                if let task = currentTask, !task.completed {
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        HStack(spacing: PremiumTheme.Spacing.sm) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.blue)
                            Text("Aktuell")
                                .font(PremiumTheme.Typography.bodySM)
                                .foregroundColor(PremiumTheme.Colors.textSecondary)
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                        .padding(.vertical, PremiumTheme.Spacing.sm)
                        .glassmorphism()
                        
                        TaskDetailCard(
                            task: task,
                            isCurrent: true,
                            onComplete: { onTaskComplete(task.id) },
                            onUploadProof: { onUploadProof(task.id) }
                        )
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.xl)
                }
                
                // All Tasks
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.lg) {
                    Text("Tagesübersicht")
                        .font(PremiumTheme.Typography.headlineMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    ForEach(dayPlan.tasks) { task in
                        TaskDetailCard(
                            task: task,
                            isCurrent: false,
                            onComplete: { onTaskComplete(task.id) },
                            onUploadProof: { onUploadProof(task.id) }
                        )
                    }
                }
                .padding(.horizontal, PremiumTheme.Spacing.xl)
                .padding(.bottom, PremiumTheme.Spacing.xxl)
            }
        }
    }
    
    private func getFormattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMMM · HH:mm"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: Date())
    }
}

struct TaskDetailCard: View {
    let task: Task
    let isCurrent: Bool
    let onComplete: () -> Void
    let onUploadProof: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
            HStack {
                if let category = task.category {
                    CategoryBadge(category: category)
                }
                
                Spacer()
                
                if let startTime = task.suggestedStartTime, let endTime = task.suggestedEndTime {
                    Text("\(startTime) - \(endTime)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                }
            }
            
            Text(task.title)
                .font(PremiumTheme.Typography.bodyMD)
                .foregroundColor(PremiumTheme.Colors.textPrimary)
            
            if let duration = task.duration {
                Text("Dauer: \(duration / 60)h \(duration % 60)m")
                    .font(PremiumTheme.Typography.bodySM)
                    .foregroundColor(PremiumTheme.Colors.textSecondary)
            }
            
            if task.requiresProof == true && !task.completed {
                HStack(spacing: PremiumTheme.Spacing.md) {
                    Button(action: onUploadProof) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Nachweis hochladen")
                        }
                        .font(PremiumTheme.Typography.bodySM)
                        .foregroundColor(.white)
                        .padding(.horizontal, PremiumTheme.Spacing.md)
                        .padding(.vertical, PremiumTheme.Spacing.sm)
                        .background(Color.orange)
                        .cornerRadius(8)
                    }
                    
                    if task.requiresProof == false || task.verified == true {
                        Button(action: onComplete) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Als erledigt markieren")
                            }
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(.white)
                            .padding(.horizontal, PremiumTheme.Spacing.md)
                            .padding(.vertical, PremiumTheme.Spacing.sm)
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                    }
                }
            } else if !task.completed {
                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Als erledigt markieren")
                    }
                    .font(PremiumTheme.Typography.bodySM)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PremiumTheme.Spacing.sm)
                    .background(Color.green)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Erledigt")
                        .font(PremiumTheme.Typography.bodySM)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(PremiumTheme.Spacing.lg)
        .glassmorphism()
        .overlay(
            isCurrent ? Rectangle()
                .frame(width: 4)
                .foregroundColor(.blue)
                .opacity(0.8) : nil,
            alignment: .leading
        )
    }
}





