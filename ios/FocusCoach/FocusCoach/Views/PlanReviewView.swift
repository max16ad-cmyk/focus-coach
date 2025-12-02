//
//  PlanReviewView.swift
//  FocusCoach
//
//  Plan Review - Review & Confirm Analyzed Tasks
//

import SwiftUI

struct PlanReviewView: View {
    let tasks: [AnalyzedTask]
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: PremiumTheme.Spacing.xxl) {
                // Header
                VStack(spacing: PremiumTheme.Spacing.md) {
                    HStack(spacing: PremiumTheme.Spacing.sm) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Text("KI-Analyse abgeschlossen")
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.vertical, PremiumTheme.Spacing.sm)
                    .glassmorphism()
                    
                    Text("Dein Tagesplan")
                        .font(PremiumTheme.Typography.headlineMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    Text(getFormattedDate())
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                .padding(.top, PremiumTheme.Spacing.xxl)
                
                // Tasks Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PremiumTheme.Spacing.lg) {
                    ForEach(tasks) { task in
                        TaskCard(task: task)
                    }
                }
                .padding(.horizontal, PremiumTheme.Spacing.xl)
                
                // CTA Buttons
                HStack(spacing: PremiumTheme.Spacing.md) {
                    Button("Abbrechen") {
                        onCancel()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Plan bestätigen") {
                        onConfirm()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, PremiumTheme.Spacing.xl)
                .padding(.bottom, PremiumTheme.Spacing.xxl)
            }
        }
    }
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: Date())
    }
}

struct TaskCard: View {
    let task: AnalyzedTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
            // Time Badge
            HStack {
                Text("\(task.suggestedStartTime) - \(task.suggestedEndTime)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(PremiumTheme.Colors.textMuted)
                
                Spacer()
                
                CategoryBadge(category: task.category)
            }
            
            // Title
            Text(task.title)
                .font(PremiumTheme.Typography.bodyMD)
                .foregroundColor(PremiumTheme.Colors.textPrimary)
            
            // Duration
            Text("Dauer: \(task.duration / 60)h \(task.duration % 60)m")
                .font(PremiumTheme.Typography.bodySM)
                .foregroundColor(PremiumTheme.Colors.textSecondary)
            
            // Proof Requirement
            if task.requiresProof {
                HStack(spacing: PremiumTheme.Spacing.sm) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.orange)
                    Text(task.proofDescription.isEmpty ? "Nachweis erforderlich" : task.proofDescription)
                        .font(PremiumTheme.Typography.bodySM)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, PremiumTheme.Spacing.md)
                .padding(.vertical, PremiumTheme.Spacing.sm)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(PremiumTheme.Spacing.lg)
        .glassmorphism()
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(.blue.opacity(0.5)),
            alignment: .leading
        )
    }
}

struct CategoryBadge: View {
    let category: TaskCategory
    
    var body: some View {
        Text(category.rawValue)
            .font(PremiumTheme.Typography.label)
            .foregroundColor(.white)
            .padding(.horizontal, PremiumTheme.Spacing.sm)
            .padding(.vertical, 4)
            .background(categoryColor(category))
            .cornerRadius(8)
    }
    
    private func categoryColor(_ category: TaskCategory) -> Color {
        switch category {
        case .lernen: return .blue
        case .haushalt: return .green
        case .erledigung: return .orange
        case .arbeit: return .purple
        case .sport: return .red
        case .kreativ: return .pink
        }
    }
}





