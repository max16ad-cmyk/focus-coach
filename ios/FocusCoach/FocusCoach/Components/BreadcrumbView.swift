//
//  BreadcrumbView.swift
//  FocusCoach
//
//  Breadcrumb-Navigation Component (wie Craft)
//

import SwiftUI

struct BreadcrumbItem: Identifiable {
    let id: String
    let title: String
    let action: (() -> Void)?
}

struct BreadcrumbView: View {
    let items: [BreadcrumbItem]
    
    var body: some View {
        HStack(spacing: PremiumTheme.Spacing.xs) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: PremiumTheme.Spacing.xs) {
                    if index > 0 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                    
                    Button(action: {
                        item.action?()
                    }) {
                        Text(item.title)
                            .font(.system(size: 14, weight: index == items.count - 1 ? .semibold : .regular))
                            .foregroundColor(index == items.count - 1 ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textMuted)
                    }
                    .disabled(item.action == nil)
                }
            }
        }
        .padding(.horizontal, PremiumTheme.Spacing.md)
        .padding(.vertical, PremiumTheme.Spacing.sm)
    }
}

#Preview {
    BreadcrumbView(items: [
        BreadcrumbItem(id: "1", title: "Heute", action: nil),
        BreadcrumbItem(id: "2", title: "Routinen", action: nil),
        BreadcrumbItem(id: "3", title: "Morgen-Routine", action: nil)
    ])
    .background(PremiumTheme.Colors.backgroundMain)
}




