//
//  PlanCreationView.swift
//  FocusCoach
//
//  Plan Creation - Text Input & AI Analysis
//

import SwiftUI

struct PlanCreationView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var planInput = ""
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var analyzedTasks: [AnalyzedTask] = []
    
    let onPlanCreated: (DayPlan) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: PremiumTheme.Spacing.xxl) {
                // Header
                VStack(spacing: PremiumTheme.Spacing.md) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundColor(PremiumTheme.Colors.ralphLaurenBlue)
                    
                    Text("Tagesplan erstellen")
                        .font(PremiumTheme.Typography.headlineMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    Text("Beschreibe deine Aufgaben und ich strukturiere sie für dich.")
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, PremiumTheme.Spacing.xxl)
                
                // Show Plan Review if tasks analyzed
                Group {
                    if !analyzedTasks.isEmpty {
                        PlanReviewView(
                            tasks: analyzedTasks,
                            onConfirm: {
                                // Convert analyzed tasks to DayPlan
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                let today = dateFormatter.string(from: Date())
                                
                                let tasks = analyzedTasks.map { analyzedTask in
                                    Task(
                                        id: analyzedTask.id,
                                        title: analyzedTask.title,
                                        completed: false,
                                        isAiGenerated: true,
                                        category: analyzedTask.category,
                                        duration: analyzedTask.duration,
                                        requiresProof: analyzedTask.requiresProof,
                                        proofType: analyzedTask.proofType == "photo" ? .photo : nil,
                                        proofDescription: analyzedTask.proofDescription,
                                        suggestedStartTime: analyzedTask.suggestedStartTime,
                                        suggestedEndTime: analyzedTask.suggestedEndTime,
                                        status: .pending,
                                        createdAt: Int64(Date().timeIntervalSince1970 * 1000)
                                    )
                                }
                                
                                let dayPlan = DayPlan(
                                    id: today,
                                    userId: firebaseService.currentUser?.id ?? "",
                                    date: today,
                                    tasks: tasks,
                                    createdAt: Int64(Date().timeIntervalSince1970 * 1000),
                                    confirmed: true
                                )
                                
                                onPlanCreated(dayPlan)
                            },
                            onCancel: {
                                analyzedTasks = []
                            }
                        )
                    } else {
                        // Input Form
                        VStack(spacing: PremiumTheme.Spacing.lg) {
                            TextEditor(text: $planInput)
                                .frame(minHeight: 240)
                                .padding()
                                .glassmorphism()
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .scrollContentBackground(.hidden)
                            
                            if let error = errorMessage {
                                Text(error)
                                    .font(PremiumTheme.Typography.bodySM)
                                    .foregroundColor(PremiumTheme.Colors.error)
                            }
                            
                            // Buttons
                            HStack(spacing: PremiumTheme.Spacing.md) {
                                Button("Abbrechen") {
                                    onCancel()
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                
                                Button(action: handleCreatePlan) {
                                    HStack(spacing: PremiumTheme.Spacing.sm) {
                                        if isAnalyzing {
                                            ProgressView()
                                                .tint(.white)
                                            Text("KI analysiert...")
                                        } else {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 16))
                                            Text("Plan erstellen")
                                        }
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(planInput.trimmingCharacters(in: .whitespaces).isEmpty || isAnalyzing)
                            }
                        
                        // Tips
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            HStack(spacing: PremiumTheme.Spacing.xs) {
                                Image(systemName: "lightbulb")
                                    .font(.system(size: 14))
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                Text("Tipps für bessere Ergebnisse:")
                                    .font(PremiumTheme.Typography.label)
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                            }
                            
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                TipRow("• Gib ungefähre Zeiten an (z.B. \"1 Stunde\", \"30 Minuten\")")
                                TipRow("• Sei spezifisch (z.B. \"Mathe Kapitel 5 lernen\" statt nur \"lernen\")")
                                TipRow("• Eine Zeile pro Aufgabe für bessere Struktur")
                            }
                        }
                        .padding()
                        .glassmorphism(opacity: 0.05)
                        }
                    }
                }
                .padding(.horizontal, PremiumTheme.Spacing.xl)
            }
        }
    }
    
    private func handleCreatePlan() {
        guard !planInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isAnalyzing = true
        errorMessage = nil
        
        _Concurrency.Task {
            do {
                let result = try await GeminiService.shared.analyzeTasks(planInput)
                
                await MainActor.run {
                    isAnalyzing = false
                    analyzedTasks = result.tasks
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = "Fehler bei der Analyse: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct TipRow: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(PremiumTheme.Typography.bodySM)
            .foregroundColor(PremiumTheme.Colors.textSecondary)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PremiumTheme.Typography.bodyMD)
            .fontWeight(.semibold)
            .foregroundColor(PremiumTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                    .fill(PremiumTheme.Colors.ralphLaurenBlue)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PremiumTheme.Typography.bodyMD)
            .foregroundColor(PremiumTheme.Colors.textPrimary)
            .padding()
            .glassmorphism()
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

