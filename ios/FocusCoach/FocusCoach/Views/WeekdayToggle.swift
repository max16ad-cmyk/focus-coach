//
//  WeekdayToggle.swift
//  FocusCoach
//
//  Toggle Button für Wochentage
//

import SwiftUI

struct WeekdayToggle: View {
    let day: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(day)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textMuted)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                        .fill(isSelected ? PremiumTheme.Colors.pendingBlue.opacity(0.2) : PremiumTheme.Colors.backgroundCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                .stroke(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.borderDefault, lineWidth: isSelected ? 2 : 1)
                        )
                )
        }
    }
}

