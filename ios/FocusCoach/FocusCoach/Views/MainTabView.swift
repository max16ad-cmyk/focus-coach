//
//  MainTabView.swift
//  FocusCoach
//
//  Main Navigation - 3 Tabs: Heute, Planung, Notizen
//

import SwiftUI

enum MainTab: String, CaseIterable {
    case heute = "Heute"
    case aufgaben = "Aufgaben"
    case notizen = "Notizen"
    case einstellungen = "Einstellungen"
    
    var icon: String {
        switch self {
        case .heute: return "calendar"
        case .aufgaben: return "plus.circle.fill"
        case .notizen: return "note.text"
        case .einstellungen: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var selectedTab: MainTab = .heute
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $selectedTab) {
                    HeuteView()
                        .tag(MainTab.heute)
                    
                    AufgabenView()
                        .tag(MainTab.aufgaben)
                    
                    NotizenView()
                        .tag(MainTab.notizen)
                    
                    SettingsMainView()
                        .tag(MainTab.einstellungen)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            // Verhindere Tab-Wechsel wenn auf Aufgaben-Tab und horizontaler Swipe
                            if selectedTab == .aufgaben {
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    // Horizontaler Swipe - verhindere Tab-Wechsel
                                    return
                                }
                            }
                        }
                )
                
                // Bottom Navigation - EQUINOX+ Style
                HStack(spacing: 0) {
                    ForEach(MainTab.allCases, id: \.self) { tab in
                        TabButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            action: { selectedTab = tab }
                        )
                    }
                }
                .frame(height: 70)
                .background(PremiumTheme.Colors.backgroundMain)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(PremiumTheme.Colors.borderDefault),
                    alignment: .top
                )
            }
        }
    }
}

struct TabButton: View {
    let tab: MainTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textMuted)
                
                Text(tab.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PremiumTheme.Spacing.sm)
        }
    }
}

