//
//  VoiceInputButtonForNotes.swift
//  FocusCoach
//
//  Simple Voice Input Button for Notes (just transcription, no parsing)
//

import SwiftUI

struct VoiceInputButtonForNotes: View {
    @StateObject private var voiceService = VoiceInputService.shared
    @State private var showingVoiceInput = false
    @State private var transcribedText = ""
    
    let onTextRecognized: (String) -> Void
    
    var body: some View {
        Button(action: {
            showingVoiceInput = true
        }) {
            Image(systemName: "mic.fill")
                .font(.system(size: 20, weight: .medium))
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
                                            PremiumTheme.Colors.pendingBlue.opacity(0.3),
                                            PremiumTheme.Colors.pendingBlue.opacity(0.1)
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
                                            PremiumTheme.Colors.pendingBlue.opacity(0.5),
                                            PremiumTheme.Colors.pendingBlue.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: PremiumTheme.Colors.pendingBlue.opacity(0.3), radius: 20, x: 0, y: 10)
                        .shadow(color: PremiumTheme.Colors.pendingBlue.opacity(0.2), radius: 5, x: 0, y: 2)
                )
        }
        .sheet(isPresented: $showingVoiceInput) {
            SimpleVoiceInputView(onTextRecognized: { text in
                onTextRecognized(text)
                showingVoiceInput = false
            })
        }
    }
}

struct SimpleVoiceInputView: View {
    @StateObject private var voiceService = VoiceInputService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    
    let onTextRecognized: (String) -> Void
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: PremiumTheme.Spacing.xl) {
                Spacer()
                
                // Microphone Circle
                ZStack {
                    // Pulsing circles
                    if voiceService.isListening {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(
                                    PremiumTheme.Colors.pendingBlue.opacity(0.6 - Double(index) * 0.2),
                                    lineWidth: 2
                                )
                                .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                                .scaleEffect(voiceService.isListening ? 1.2 : 1.0)
                                .opacity(voiceService.isListening ? 0.0 : 0.6)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.2),
                                    value: voiceService.isListening
                                )
                        }
                    }
                    
                    // Main microphone circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: voiceService.isListening ? [
                                            PremiumTheme.Colors.pendingBlue.opacity(0.4),
                                            PremiumTheme.Colors.pendingBlue.opacity(0.2)
                                        ] : [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)
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
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    // Microphone icon
                    Image(systemName: voiceService.isListening ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(voiceService.isListening ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textSecondary)
                }
                
                // Status text
                Text(voiceService.isListening ? "Ich höre zu..." : "Tippe auf Start")
                    .font(PremiumTheme.Typography.bodyLG)
                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                
                // Transcription
                VStack(spacing: PremiumTheme.Spacing.xs) {
                    Text("Transkription")
                        .font(PremiumTheme.Typography.label)
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                        .tracking(PremiumTheme.Typography.labelTracking)
                    
                    ScrollView {
                        Text(voiceService.recognizedText.isEmpty ? "Warte auf Eingabe..." : voiceService.recognizedText)
                            .font(PremiumTheme.Typography.bodyLG)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(PremiumTheme.Spacing.md)
                    }
                    .frame(maxHeight: 200)
                    .background(
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
                    )
                }
                .padding(.horizontal, PremiumTheme.Spacing.lg)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: PremiumTheme.Spacing.md) {
                    // Cancel Button
                    Button(action: {
                        voiceService.stopListening()
                        dismiss()
                    }) {
                        Text("Abbrechen")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                            .padding(.vertical, PremiumTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    
                    // Stop/Start Button
                    Button(action: {
                        if voiceService.isListening {
                            voiceService.stopListening()
                            // Save transcribed text
                            if !voiceService.recognizedText.isEmpty {
                                isProcessing = true
                                onTextRecognized(voiceService.recognizedText)
                                dismiss()
                            } else {
                                dismiss()
                            }
                        } else {
                            voiceService.startListening()
                        }
                    }) {
                        HStack(spacing: PremiumTheme.Spacing.sm) {
                            Image(systemName: voiceService.isListening ? "stop.fill" : "mic.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(voiceService.isListening ? "Stoppen & Speichern" : "Start")
                                .font(PremiumTheme.Typography.bodyMD)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                        .padding(.vertical, PremiumTheme.Spacing.md)
                        .background(
                            LinearGradient(
                                colors: [
                                    PremiumTheme.Colors.pendingBlue,
                                    PremiumTheme.Colors.pendingBlue.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(PremiumTheme.CornerRadius.md)
                        .shadow(color: PremiumTheme.Colors.pendingBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isProcessing)
                }
                .padding(.horizontal, PremiumTheme.Spacing.lg)
                .padding(.bottom, PremiumTheme.Spacing.xl)
            }
        }
        .onAppear {
            if !voiceService.isListening {
                voiceService.startListening()
            }
        }
        .onDisappear {
            if voiceService.isListening {
                voiceService.stopListening()
            }
        }
    }
}

