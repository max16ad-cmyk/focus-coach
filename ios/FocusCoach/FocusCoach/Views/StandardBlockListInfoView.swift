//
//  StandardBlockListInfoView.swift
//  FocusCoach
//
//  Info-View für Standard-Blocklisten mit App-Hinweisen
//

import SwiftUI
import FamilyControls

struct StandardBlockListInfoView: View {
    let blockList: BlockList
    let onAddApps: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
            if blockList.appTokens.isEmpty && !blockList.urls.isEmpty {
                HStack(spacing: PremiumTheme.Spacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.info)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Apps hinzufügen")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        Text("Diese Blockliste enthält bereits URLs. Tippe auf 'Apps auswählen', um Apps hinzuzufügen.")
                            .font(.system(size: 11))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                    
                    Spacer()
                    
                    Button(action: onAddApps) {
                        Text("Hinzufügen")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    }
                }
                .padding(PremiumTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                        .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                )
            }
        }
    }
}

