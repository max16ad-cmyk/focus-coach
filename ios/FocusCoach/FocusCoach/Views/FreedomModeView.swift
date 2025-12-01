//
//  FreedomModeView.swift
//  FocusCoach
//
//  Freedom Mode - All Tasks Completed
//

import SwiftUI

struct FreedomModeView: View {
    let completedTasks: [Task]
    
    var body: some View {
        ScrollView {
            VStack(spacing: PremiumTheme.Spacing.xxl) {
                // Header
                VStack(spacing: PremiumTheme.Spacing.md) {
                    Text("🎉")
                        .font(.system(size: 64))
                    
                    Text("Alle Aufgaben erledigt!")
                        .font(PremiumTheme.Typography.headlineMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    Text("Du hast heute \(completedTasks.count) Aufgabe(n) erfolgreich abgeschlossen.")
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, PremiumTheme.Spacing.xxl)
                
                // Completed Tasks List
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.lg) {
                    Text("Erledigte Aufgaben")
                        .font(PremiumTheme.Typography.headlineMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    ForEach(completedTasks) { task in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text(task.title)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            Spacer()
                        }
                        .padding(PremiumTheme.Spacing.md)
                        .glassmorphism()
                    }
                }
                .padding(.horizontal, PremiumTheme.Spacing.xl)
                .padding(.bottom, PremiumTheme.Spacing.xxl)
            }
        }
    }
}




