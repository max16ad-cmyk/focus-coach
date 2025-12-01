//
//  CategorizedAppPickerView.swift
//  FocusCoach
//
//  Improved App Picker with Categories and Screen Time sorting
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct CategorizedAppPickerView: View {
    @Binding var selectedTokens: Set<ApplicationToken>
    let onSave: (Set<ApplicationToken>) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var blockingService = BlockingService.shared
    @State private var selectedCategory: AppCategory = .socialMedia
    @State private var familyActivitySelection = FamilyActivitySelection()
    
    init(selectedTokens: Binding<Set<ApplicationToken>>, onSave: @escaping (Set<ApplicationToken>) -> Void) {
        self._selectedTokens = selectedTokens
        self.onSave = onSave
    }
    
    enum AppCategory: String, CaseIterable {
        case socialMedia = "Soziale Netzwerke"
        case entertainment = "Unterhaltung"
        case games = "Spiele"
        case productivity = "Produktivität"
        case news = "Nachrichten"
        case shopping = "Shopping"
        case all = "Alle Apps"
        
        var icon: String {
            switch self {
            case .socialMedia: return "person.2.fill"
            case .entertainment: return "tv.fill"
            case .games: return "gamecontroller.fill"
            case .productivity: return "briefcase.fill"
            case .news: return "newspaper.fill"
            case .shopping: return "cart.fill"
            case .all: return "square.grid.2x2.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumTheme.Colors.backgroundMain
                    .ignoresSafeArea()
                
                // FamilyActivityPicker direkt anzeigen - er hat sein eigenes Layout
                FamilyActivityPicker(selection: $familyActivitySelection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Apps auswählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        // Extract tokens from selection
                        handleSelection()
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // Load existing selection
                familyActivitySelection = blockingService.familyActivitySelection
            }
        }
    }
    
    private func handleSelection() {
        // Store the selection in BlockingService
        let blockingService = BlockingService.shared
        blockingService.storeSelection(familyActivitySelection)
        
        // Update the selection in BlockingService
        blockingService.familyActivitySelection = familyActivitySelection
        
        // Update selectedTokens binding
        selectedTokens = familyActivitySelection.applicationTokens
        
        // Call onSave callback with tokens
        onSave(familyActivitySelection.applicationTokens)
        
        dismiss()
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let category: CategorizedAppPickerView.AppCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: PremiumTheme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textMuted)
            .padding(.horizontal, PremiumTheme.Spacing.md)
            .padding(.vertical, PremiumTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                    .fill(isSelected ? PremiumTheme.Colors.pendingBlue.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CategorizedAppPickerView(
        selectedTokens: Binding.constant([]),
        onSave: { _ in }
    )
}

