//
//  VoiceInputView.swift
//  FocusCoach
//
//  Voice Input mit Live-Vorschaufeldern - Komplett neu aufgebaut
//

import SwiftUI

struct VoiceInputView: View {
    @StateObject private var voiceService = VoiceInputService.shared
    @StateObject private var viewModel = VoiceInputViewModel()
    @StateObject private var taskRepository = TaskRepository.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header mit Mikrofon und Wellen
                VStack(spacing: PremiumTheme.Spacing.md) {
                    // Synth Waves Animation im Kreis
                    SynthWaveView(
                        isListening: .constant(voiceService.isListening),
                        audioLevel: $voiceService.audioLevel
                    )
                    .frame(width: 120, height: 120) // Quadratischer Container für Kreis
                    .padding(.top, PremiumTheme.Spacing.md)
                    
                    // Status Text
                    Text(voiceService.isListening ? "Ich höre zu..." : "Tippe zum Starten")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                .padding(.horizontal, PremiumTheme.Spacing.lg)
                
                // Transkription
                if !voiceService.recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                        Text("Transkription")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                        
                        ScrollView {
                            Text(voiceService.recognizedText)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .multilineTextAlignment(.leading)
                                .padding(PremiumTheme.Spacing.sm)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 100)
                        .background(transcriptionBackground)
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                    .padding(.top, PremiumTheme.Spacing.md)
                }
                
                // Live-Vorschaufelder (unterstützt mehrere Tasks)
                if !viewModel.tasks.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            Text("Vorschau (\(viewModel.tasks.count) \(viewModel.tasks.count == 1 ? "Aufgabe" : "Aufgaben"))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                            
                            ForEach(Array(viewModel.tasks.enumerated()), id: \.offset) { index, task in
                                VStack(spacing: PremiumTheme.Spacing.sm) {
                                    // Task-Nummer wenn mehrere
                                    if viewModel.tasks.count > 1 {
                                        Text("Aufgabe \(index + 1)")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                    }
                                    
                                    // Titel
                                    if !task.cleanedTitle.isEmpty {
                                        previewField(
                                            icon: "text.bubble",
                                            label: "Titel",
                                            value: task.cleanedTitle
                                        )
                                    }
                                    
                                    // Datum
                                    if let date = task.date {
                                        previewField(
                                            icon: "calendar",
                                            label: "Datum",
                                            value: formatDate(date)
                                        )
                                    }
                                    
                                    // Zeit
                                    if let startTime = task.startTime {
                                        let timeString = if let endTime = task.endTime {
                                            "\(startTime) - \(endTime)"
                                        } else {
                                            startTime
                                        }
                                        previewField(
                                            icon: "clock",
                                            label: "Zeit",
                                            value: timeString
                                        )
                                    }
                                    
                                    // Notizen
                                    if let notes = task.notes, !notes.isEmpty {
                                        previewField(
                                            icon: "note.text",
                                            label: "Notizen",
                                            value: notes
                                        )
                                    }
                                }
                                .padding(PremiumTheme.Spacing.md)
                                .background(previewBackground)
                            }
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                    .frame(maxHeight: 300)
                    .padding(.top, PremiumTheme.Spacing.md)
                }
                
                Spacer()
                
                // Buttons - Verbesserte Anordnung mit mehr Abstand
                VStack(spacing: PremiumTheme.Spacing.md) {
                    // Speichern Button (oben, wenn vorhanden) - Volle Breite
                    if !viewModel.tasks.isEmpty && !voiceService.isListening {
                        Button(action: {
                            saveTasks()
                        }) {
                            HStack(spacing: PremiumTheme.Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Speichern (\(viewModel.tasks.count) \(viewModel.tasks.count == 1 ? "Aufgabe" : "Aufgaben"))")
                                    .font(PremiumTheme.Typography.bodyMD)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PremiumTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                PremiumTheme.Colors.accentGreen,
                                                PremiumTheme.Colors.accentGreen.opacity(0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: PremiumTheme.Colors.accentGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isSaving)
                    }
                    
                    // Abbrechen & Stoppen/Start Buttons - Nebeneinander
                    HStack(spacing: PremiumTheme.Spacing.md) {
                        // Abbrechen
                        Button(action: {
                            voiceService.stopListening()
                            viewModel.reset()
                            dismiss()
                        }) {
                            Text("Abbrechen")
                                .font(PremiumTheme.Typography.bodyMD)
                                .fontWeight(.medium)
                                .foregroundColor(PremiumTheme.Colors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Stoppen/Start
                        Button(action: {
                            if voiceService.isListening {
                                voiceService.stopListening()
                                viewModel.stopAnalysis()
                                // Finale Analyse wenn Text vorhanden
                                if !voiceService.recognizedText.isEmpty {
                                    _Concurrency.Task {
                                        _ = await viewModel.analyzeFinal(text: voiceService.recognizedText)
                                    }
                                }
                            } else {
                                viewModel.reset()
                                voiceService.startListening()
                            }
                        }) {
                            HStack(spacing: PremiumTheme.Spacing.sm) {
                                Image(systemName: voiceService.isListening ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(voiceService.isListening ? "Stoppen" : "Start")
                                    .font(PremiumTheme.Typography.bodyMD)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PremiumTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                PremiumTheme.Colors.pendingBlue,
                                                PremiumTheme.Colors.pendingBlue.opacity(0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: PremiumTheme.Colors.pendingBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(viewModel.isAnalyzing || isSaving)
                    }
                }
                .padding(.horizontal, PremiumTheme.Spacing.lg)
                .padding(.bottom, PremiumTheme.Spacing.lg)
            }
        }
        .onAppear {
            viewModel.reset()
            if !voiceService.isListening {
                voiceService.startListening()
            }
        }
        .onDisappear {
            voiceService.stopListening()
            viewModel.stopAnalysis()
        }
        .onChange(of: voiceService.recognizedText) { newText in
            // Live-Analyse während des Sprechens
            if voiceService.isListening {
                viewModel.analyzeLive(text: newText, isListening: voiceService.isListening)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func previewField(icon: String, label: String, value: String) -> some View {
        HStack(spacing: PremiumTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(PremiumTheme.Colors.textMuted)
                Text(value)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
            }
            
            Spacer()
        }
    }
    
    private var transcriptionBackground: some View {
        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private var previewBackground: some View {
        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                PremiumTheme.Colors.pendingBlue.opacity(0.1),
                                PremiumTheme.Colors.pendingBlue.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                    .stroke(
                        PremiumTheme.Colors.pendingBlue.opacity(0.3),
                        lineWidth: 1
                    )
            )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "d. MMMM yyyy"
            formatter.locale = Locale(identifier: "de_DE")
            return formatter.string(from: date)
        }
        return dateString
    }
    
    // MARK: - Task Creation
    
    private func saveTasks() {
        guard !viewModel.tasks.isEmpty else { return }
        
        isSaving = true
        
        _Concurrency.Task {
            do {
                // Speichere alle Tasks
                for taskResult in viewModel.tasks {
                    let task = Task(
                        title: taskResult.cleanedTitle,
                        completed: false,
                        status: .pending,
                        scheduledDate: taskResult.date,
                        scheduledStartTime: taskResult.startTime,
                        scheduledEndTime: taskResult.endTime,
                        notes: taskResult.notes
                    )
                    
                    try await taskRepository.saveTask(task)
                }
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    viewModel.error = "Fehler beim Speichern: \(error.localizedDescription)"
                }
            }
        }
    }
}
