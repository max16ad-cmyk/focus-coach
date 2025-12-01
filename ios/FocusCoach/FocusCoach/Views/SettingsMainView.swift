//
//  SettingsMainView.swift
//  FocusCoach
//
//  Main Settings View - All app settings in one place
//

import SwiftUI

struct SettingsMainView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var showingBlockingSettings = false
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: PremiumTheme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Einstellungen")
                            .font(PremiumTheme.Typography.headlineLG)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        Text("Verwalte deine App-Einstellungen")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    
                    // Settings Sections
                    VStack(spacing: PremiumTheme.Spacing.md) {
                        // Blocking Section
                        SettingsSection(
                            title: "Blockierung",
                            icon: "lock.shield.fill",
                            iconColor: PremiumTheme.Colors.pendingBlue
                        ) {
                            VStack(spacing: PremiumTheme.Spacing.md) {
                                HStack {
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                        Text("App- & Website-Blockierung")
                                            .font(PremiumTheme.Typography.bodyMD)
                                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                                        
                                        Text("Blockiere Apps und Websites während aktiver Tasks")
                                            .font(PremiumTheme.Typography.bodySM)
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture(perform: {
                                    showingBlockingSettings = true
                                })
                                
                                Divider()
                                    .background(PremiumTheme.Colors.borderDefault)
                                
                                // Auto-Rotate Backgrounds
                                HStack {
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                        Text("Hintergrundbilder automatisch wechseln")
                                            .font(PremiumTheme.Typography.bodyMD)
                                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                                        
                                        Text("Blockierungsseiten wechseln automatisch zwischen verschiedenen Hintergrundbildern")
                                            .font(PremiumTheme.Typography.bodySM)
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: Binding(
                                        get: { BlockingService.shared.autoRotateBackgrounds },
                                        set: { BlockingService.shared.setAutoRotateBackgrounds($0) }
                                    ))
                                    .tint(PremiumTheme.Colors.pendingBlue)
                                }
                            }
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
                        
                        // Account Section
                        SettingsSection(
                            title: "Account",
                            icon: "person.circle.fill",
                            iconColor: PremiumTheme.Colors.textMuted
                        ) {
                            VStack(spacing: PremiumTheme.Spacing.md) {
                                HStack {
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                        Text("E-Mail")
                                            .font(PremiumTheme.Typography.bodyMD)
                                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                                        
                                        Text(firebaseService.currentUser?.email ?? "Nicht angemeldet")
                                            .font(PremiumTheme.Typography.bodySM)
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(PremiumTheme.Colors.borderDefault)
                                
                                Button(action: logoutAction) {
                                    HStack {
                                        Text("Abmelden")
                                            .font(PremiumTheme.Typography.bodyMD)
                                            .foregroundColor(PremiumTheme.Colors.error)
                                        
                                        Spacer()
                                    }
                                }
                            }
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
                        
                        // About Section
                        SettingsSection(
                            title: "Über",
                            icon: "info.circle.fill",
                            iconColor: PremiumTheme.Colors.textMuted
                        ) {
                            VStack(spacing: PremiumTheme.Spacing.md) {
                                HStack {
                                    Text("Version")
                                        .font(PremiumTheme.Typography.bodyMD)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("1.0.0")
                                        .font(PremiumTheme.Typography.bodySM)
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                }
                                
                                Divider()
                                    .background(PremiumTheme.Colors.borderDefault)
                                
                                HStack {
                                    Text("Focus Coach")
                                        .font(PremiumTheme.Typography.bodyMD)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    
                                    Spacer()
                                }
                            }
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
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.xl)
                }
            }
        }
        .sheet(isPresented: $showingBlockingSettings) {
            NavigationView {
                BlockingSettingsView()
                    .navigationTitle("Blockierung")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Fertig") {
                                showingBlockingSettings = false
                            }
                            .foregroundColor(PremiumTheme.Colors.pendingBlue)
                        }
                    }
            }
        }
    }
    
    private var logoutAction: () -> Void {
        {
            _Concurrency.Task {
                try? await firebaseService.logout()
            }
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
            HStack(spacing: PremiumTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(PremiumTheme.Colors.textMuted)
                    .tracking(0.5)
            }
            
            content
        }
    }
}

#Preview {
    SettingsMainView()
        .environmentObject(FirebaseService.shared)
}

