//
//  Theme.swift
//  FocusCoach
//
//  EQUINOX+ Style Theme - Premium Dark Design
//

import SwiftUI

struct PremiumTheme {
    // MARK: - Colors (EQUINOX+ Style)
    
    struct Colors {
        // Background - Pure black like Origin
        static let backgroundMain = Color.black
        static let backgroundElevated = Color(hex: "0a0a0a")
        static let backgroundCard = Color(hex: "1a1a1a") // Origin style card background
        static let backgroundGlass = Color.white.opacity(0.02)
        
        // Text - White and light grey
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "a8a8a8")
        static let textMuted = Color(hex: "6b6b6b")
        static let textAccent = Color(hex: "f5f5f5")
        
        // Primary - Subtle accent colors
        static let primary = Color(hex: "7a94a8")
        static let primaryLight = Color(hex: "8ea8ba")
        static let primaryDark = Color(hex: "5d7488")
        
        // Feature Colors - Productivity Green (completed) & Blue (pending)
        static let accentBlue = Color(hex: "00C896") // Fresh turquoise/green
        static let accentGreen = Color(hex: "00D9A5") // Bright productivity green
        static let accentBlueLight = Color(hex: "00E5B3") // Lighter green
        static let accentGreenLight = Color(hex: "00F0C0") // Lightest green
        static let productivityGreen = Color(hex: "00D9A5") // Primary productivity green (completed)
        static let productivityGreenLight = Color(hex: "00E5B3") // Lighter variant
        static let pendingBlue = Color(hex: "5B8DFF") // Bright blue for pending tasks
        static let pendingBlueLight = Color(hex: "7BA3FF") // Lighter blue variant
        // Legacy support
        static let ralphLaurenBlue = Color(hex: "5B8DFF") // Now using pending blue
        static let ralphLaurenBlueLight = Color(hex: "7BA3FF") // Lighter variant
        
        // Status
        static let success = Color(hex: "4ade80")
        static let warning = Color(hex: "fbbf24")
        static let error = Color(hex: "f87171")
        static let info = Color(hex: "60a5fa")
        
        // Borders - Very subtle
        static let borderDefault = Color.white.opacity(0.08)
        static let borderLight = Color.white.opacity(0.05)
        static let borderStrong = Color.white.opacity(0.12)
        
        // Button backgrounds
        static let buttonPrimary = Color(hex: "1a1a1a")
        static let buttonSecondary = Color.clear
    }
    
    // MARK: - Typography (EQUINOX+ Style)
    
    struct Typography {
        // Headlines - Serif (like EQUINOX+)
        static let headlineXL = Font.system(size: 36, weight: .bold, design: .serif)
        static let headlineLG = Font.system(size: 28, weight: .bold, design: .serif)
        static let headlineMD = Font.system(size: 24, weight: .semibold, design: .serif)
        static let headlineSM = Font.system(size: 20, weight: .semibold, design: .serif)
        
        // Body - Sans Serif
        static let bodyLG = Font.system(size: 18, weight: .regular)
        static let bodyMD = Font.system(size: 16, weight: .regular)
        static let bodySM = Font.system(size: 14, weight: .regular)
        static let bodyXS = Font.system(size: 12, weight: .regular)
        
        // Labels
        static let label = Font.system(size: 12, weight: .medium)
        static let labelTracking: CGFloat = 0.5
    }
    
    // MARK: - Spacing (EQUINOX+ Style - Very Generous)
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 20
        static let lg: CGFloat = 32
        static let xl: CGFloat = 40
        static let xxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Glassmorphism Modifier (EQUINOX+ Style)

struct GlassmorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var opacity: Double = 0.05
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(opacity))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
            )
    }
}

extension View {
    func glassmorphism(cornerRadius: CGFloat = 16, opacity: Double = 0.05) -> some View {
        modifier(GlassmorphismModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - EQUINOX+ Style Components

struct HighlightTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(PremiumTheme.Typography.label)
            .foregroundColor(PremiumTheme.Colors.textPrimary)
            .padding(.horizontal, PremiumTheme.Spacing.sm)
            .padding(.vertical, PremiumTheme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                    .fill(PremiumTheme.Colors.backgroundGlass)
            )
    }
}

struct EquinoxButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: PremiumTheme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                Text(title)
                    .font(PremiumTheme.Typography.bodyMD)
                    .fontWeight(.semibold)
            }
            .foregroundColor(style == .primary ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PremiumTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                    .fill(style == .primary ? PremiumTheme.Colors.ralphLaurenBlue : PremiumTheme.Colors.buttonSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .stroke(PremiumTheme.Colors.borderDefault, lineWidth: style == .secondary ? 1 : 0)
                    )
            )
        }
    }
}
