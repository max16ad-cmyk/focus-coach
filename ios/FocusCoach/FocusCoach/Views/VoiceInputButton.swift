//
//  VoiceInputButton.swift
//  FocusCoach
//
//  Floating Voice Input Button
//

import SwiftUI

struct VoiceInputButton: View {
    @StateObject private var voiceService = VoiceInputService.shared
    @State private var showVoiceInputView = false
    
    var body: some View {
        Button(action: {
            showVoiceInputView = true
        }) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: voiceService.isListening ? [
                                        Color.red.opacity(0.3),
                                        Color.red.opacity(0.1)
                                    ] : [
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
                                    colors: voiceService.isListening ? [
                                        Color.red.opacity(0.6),
                                        Color.red.opacity(0.2)
                                    ] : [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: voiceService.isListening ? 2 : 1
                            )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.3), radius: voiceService.isListening ? 15 : 10, x: 0, y: 5)
                
                if voiceService.isListening {
                    // Pulsing animation
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 56, height: 56)
                        .scaleEffect(voiceService.isListening ? 1.2 : 1.0)
                        .opacity(voiceService.isListening ? 0.0 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: false),
                            value: voiceService.isListening
                        )
                }
                
                Image(systemName: "mic")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
            }
        }
        .sheet(isPresented: $showVoiceInputView) {
            VoiceInputView()
        }
    }
}

