//
//  ScreenTimeAnalysisView.swift
//  FocusCoach
//
//  View für Bildschirmzeit-Analyse und Erstellung personalisierter Blockliste
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct ScreenTimeAnalysisView: View {
    let onComplete: (Set<ApplicationToken>, String) -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var screenTimeAnalyzer = ScreenTimeAnalyzer.shared
    @StateObject private var blockingService = BlockingService.shared
    @State private var selectedTokens: Set<ApplicationToken> = []
    @State private var familyActivitySelection = FamilyActivitySelection()
    @State private var showingAppPicker = false
    @State private var analysisSummary: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumTheme.Colors.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 48))
                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, PremiumTheme.Spacing.lg)
                            
                            Text("Meine Zeitfresser")
                                .font(PremiumTheme.Typography.headlineLG)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("Wähle Apps aus, die du als Zeitfresser identifiziert hast. Die App erstellt automatisch eine personalisierte Blockliste.")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                        
                        // Analyse-Zusammenfassung
                        if let summary = analysisSummary {
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                    Text("Analyse-Info")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                }
                                
                                Text(summary)
                                    .font(.system(size: 13))
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                    .lineSpacing(4)
                            }
                            .padding(PremiumTheme.Spacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(PremiumTheme.Colors.pendingBlue.opacity(0.1))
                            )
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                        }
                        
                        // App-Auswahl
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            HStack {
                                Text("Apps auswählen")
                                    .font(PremiumTheme.Typography.headlineSM)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                
                                Spacer()
                                
                                Text("\(selectedTokens.count) ausgewählt")
                                    .font(.system(size: 12))
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                            }
                            
                            Button(action: {
                                showingAppPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                    Text("Apps auswählen")
                                        .font(PremiumTheme.Typography.bodyMD)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Ausgewählte Apps anzeigen
                            if !selectedTokens.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    Text("Ausgewählte Apps:")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    // Zeige App-Icons
                                    if !familyActivitySelection.applicationTokens.isEmpty && familyActivitySelection.applicationTokens.count == selectedTokens.count {
                                        FamilyActivitySelectionView(selection: familyActivitySelection)
                                            .frame(minHeight: 120)
                                    } else {
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: PremiumTheme.Spacing.sm) {
                                            ForEach(Array(selectedTokens.enumerated()), id: \.offset) { index, _ in
                                                VStack(spacing: PremiumTheme.Spacing.xs) {
                                                    Image(systemName: "app.fill")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                                    
                                                    Text("App \(index + 1)")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                                        .lineLimit(1)
                                                }
                                                .frame(width: 60, height: 60)
                                                .background(
                                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                                        .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                                                )
                                            }
                                        }
                                    }
                                }
                                .padding(PremiumTheme.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.backgroundCard.opacity(0.3))
                                )
                            }
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                        
                        // Info-Box
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.productivityGreen)
                                Text("Tipp")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                            }
                            
                            Text("Konzentriere dich auf Apps, die du als Zeitfresser identifiziert hast. Social Media Apps, Spiele und Unterhaltungs-Apps sind typische Kandidaten.")
                                .font(.system(size: 13))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                .lineSpacing(4)
                        }
                        .padding(PremiumTheme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                .fill(PremiumTheme.Colors.productivityGreen.opacity(0.1))
                        )
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                    .padding(.bottom, PremiumTheme.Spacing.xl)
                }
            }
            .navigationTitle("Bildschirmzeit-Analyse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        onCancel()
                    }
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Erstellen") {
                        let summary = screenTimeAnalyzer.generateAnalysisSummary(appCount: selectedTokens.count)
                        onComplete(selectedTokens, summary)
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                    .disabled(selectedTokens.isEmpty)
                }
            }
            .sheet(isPresented: $showingAppPicker) {
                CategorizedAppPickerView(
                    selectedTokens: $selectedTokens,
                    onSave: { tokens in
                        selectedTokens = tokens
                        familyActivitySelection = blockingService.familyActivitySelection
                    }
                )
            }
            .onAppear {
                // Starte Analyse
                screenTimeAnalyzer.analyzeScreenTime { tokens, summary in
                    selectedTokens = Set(tokens)
                    analysisSummary = summary
                }
            }
        }
    }
}

