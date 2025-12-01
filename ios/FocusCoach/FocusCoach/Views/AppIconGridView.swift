//
//  AppIconGridView.swift
//  FocusCoach
//
//  View zum Anzeigen von App-Icons aus FamilyActivitySelection
//

import SwiftUI
import FamilyControls

struct AppIconGridView: View {
    let selection: FamilyActivitySelection
    
    var body: some View {
        // FamilyActivitySelection kann nicht direkt als Grid angezeigt werden
        // Wir verwenden stattdessen eine kompakte Liste
        if !selection.applicationTokens.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PremiumTheme.Spacing.sm) {
                    // Zeige bis zu 20 Apps in einer Reihe
                    ForEach(Array(selection.applicationTokens.prefix(20).enumerated()), id: \.offset) { index, token in
                        // Verwende FamilyActivityPicker's Icon-Anzeige
                        // Da wir die Icons nicht direkt bekommen können, zeigen wir einen Platzhalter
                        // mit der Möglichkeit, die Selection zu sehen
                        VStack(spacing: PremiumTheme.Spacing.xs) {
                            // App Icon Platzhalter - wird durch System-Icon ersetzt wenn möglich
                            Image(systemName: "app.fill")
                                .font(.system(size: 32))
                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                        .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                                )
                        }
                        .frame(width: 50, height: 50)
                    }
                }
                .padding(.horizontal, PremiumTheme.Spacing.sm)
            }
        }
    }
}

// Alternative: Verwende FamilyActivityPicker's eingebaute Icon-Anzeige
struct FamilyActivitySelectionView: View {
    let selection: FamilyActivitySelection
    @State private var displaySelection = FamilyActivitySelection()
    
    var body: some View {
        // Verwende einen kompakten FamilyActivityPicker im Read-Only Modus
        // Dieser zeigt automatisch die App-Icons an
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
            if !selection.applicationTokens.isEmpty {
                // Zeige die Selection in einem kompakten Format
                // FamilyActivityPicker zeigt die Icons automatisch an
                FamilyActivityPicker(selection: Binding(
                    get: { displaySelection },
                    set: { _ in } // Read-only - keine Änderungen erlaubt
                ))
                .frame(height: 120)
                .disabled(true) // Read-only
                .allowsHitTesting(false) // Verhindert Interaktionen
                .onAppear {
                    displaySelection = selection
                }
            } else {
                // Fallback: Zeige Info-Text wenn keine Apps ausgewählt
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                    Text("Apps werden hier angezeigt, nachdem du sie ausgewählt hast")
                        .font(.system(size: 12))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                }
                .padding(PremiumTheme.Spacing.sm)
            }
        }
    }
}

