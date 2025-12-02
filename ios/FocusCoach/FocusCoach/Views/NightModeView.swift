//
//  NightModeView.swift
//  FocusCoach
//
//  Night Mode - Blocking Screen
//

import SwiftUI

struct NightModeView: View {
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: PremiumTheme.Spacing.xxl) {
                Text("🌙")
                    .font(.system(size: 64))
                
                Text("Nachtmodus aktiv")
                    .font(PremiumTheme.Typography.headlineMD)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                
                Text("Alle Ablenkungen sind blockiert.\nZeit für Ruhe und Erholung.")
                    .font(PremiumTheme.Typography.bodyMD)
                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}





