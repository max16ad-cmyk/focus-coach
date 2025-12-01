//
//  BlockingSettingsView.swift
//  FocusCoach
//
//  Settings View für App- und Website-Blockierung
//  Neue Struktur: Apps → URLs → Blocklisten → Design
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct BlockingSettingsView: View {
    @StateObject private var blockingService = BlockingService.shared
    @StateObject private var taskBlockingMonitor = TaskBlockingMonitor.shared
    @StateObject private var blockListRepository = BlockListRepository.shared
    @State private var showAppPicker = false
    @State private var showAuthorizationAlert = false
    @State private var authorizationError: String?
    @State private var showActiveTasksAlert = false
    
    private func requestAuthClosure() {
        _Concurrency.Task { @MainActor in
            await requestAuthorization()
        }
    }
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: PremiumTheme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Blockierung")
                            .font(PremiumTheme.Typography.headlineLG)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        Text("Blockiere Apps und Websites während deiner Tasks")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    
                    // Authorization Status
                    if !blockingService.isAuthorized {
                        AuthorizationCard(onRequestAuthorization: requestAuthClosure)
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                    
                    // SECTION 1: APP BLOCKIERUNGEN (Standard-Blockliste)
                    if blockingService.isAuthorized {
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            HStack {
                                Text("App Blockierungen")
                                    .font(PremiumTheme.Typography.headlineMD)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                
                                Spacer()
                                
                                Text("Standard-Blockliste")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                    .padding(.horizontal, PremiumTheme.Spacing.sm)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(PremiumTheme.Colors.pendingBlue.opacity(0.15))
                                    )
                            }
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                            
                            Button(action: {
                                // Prüfe ob aktive Tasks vorhanden sind
                                if blockingService.hasActiveTasks {
                                    showActiveTasksAlert = true
                                    return
                                }
                                showAppPicker = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                        Text("Apps auswählen")
                                            .font(PremiumTheme.Typography.headlineSM)
                                            .foregroundColor(blockingService.hasActiveTasks ? PremiumTheme.Colors.textMuted : PremiumTheme.Colors.textPrimary)
                                        
                                        if blockingService.hasActiveTasks {
                                            Text("Während aktiver Tasks kann die Blockierung nicht geändert werden")
                                                .font(PremiumTheme.Typography.bodySM)
                                                .foregroundColor(PremiumTheme.Colors.warning)
                                        } else if blockingService.familyActivitySelection.applicationTokens.isEmpty {
                                            Text("Noch keine Apps ausgewählt")
                                                .font(PremiumTheme.Typography.bodySM)
                                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                        } else {
                                            Text("\(blockingService.familyActivitySelection.applicationTokens.count) App(s) ausgewählt")
                                                .font(PremiumTheme.Typography.bodySM)
                                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(blockingService.hasActiveTasks ? PremiumTheme.Colors.textMuted.opacity(0.5) : PremiumTheme.Colors.textMuted)
                                }
                                .padding(PremiumTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(blockingService.hasActiveTasks ? PremiumTheme.Colors.backgroundCard.opacity(0.5) : PremiumTheme.Colors.backgroundCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(blockingService.hasActiveTasks)
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                            
                            // Ausgewählte Apps anzeigen (wenn vorhanden)
                            if !blockingService.familyActivitySelection.applicationTokens.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    Text("Ausgewählte Apps:")
                                        .font(PremiumTheme.Typography.bodySM)
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                                    
                                    // App Icons Grid
                                    FamilyActivitySelectionView(selection: blockingService.familyActivitySelection)
                                        .frame(height: 100)
                                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                                }
                            }
                        }
                        .padding(.top, PremiumTheme.Spacing.md)
                        
                        Divider()
                            .background(PremiumTheme.Colors.borderDefault)
                            .padding(.vertical, PremiumTheme.Spacing.md)
                        
                        // SECTION 2: WEBSEITEN BLOCKIERUNG (Standard-Blockliste)
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            HStack {
                                Text("Webseiten Blockierung")
                                    .font(PremiumTheme.Typography.headlineMD)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                
                                Spacer()
                                
                                Text("Standard-Blockliste")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                    .padding(.horizontal, PremiumTheme.Spacing.sm)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(PremiumTheme.Colors.pendingBlue.opacity(0.15))
                                    )
                            }
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                            
                            // Allgemeine Website-Blockierung
                            HStack {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                    Text("Alle Websites blockieren")
                                        .font(PremiumTheme.Typography.headlineSM)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    
                                    if blockingService.hasActiveTasks {
                                        Text("Während aktiver Tasks kann die Blockierung nicht deaktiviert werden")
                                            .font(PremiumTheme.Typography.bodySM)
                                            .foregroundColor(PremiumTheme.Colors.warning)
                                    } else {
                                        Text("Blockiert alle Websites während aktiver Tasks")
                                            .font(PremiumTheme.Typography.bodySM)
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                    }
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { blockingService.isWebsiteBlockingEnabled },
                                    set: { isOn in
                                        if isOn {
                                            blockingService.enableWebsiteBlocking()
                                        } else {
                                            // Prüfe ob aktive Tasks vorhanden sind
                                            if blockingService.hasActiveTasks {
                                                showActiveTasksAlert = true
                                                return
                                            }
                                            blockingService.disableWebsiteBlocking()
                                        }
                                    }
                                ))
                                .tint(PremiumTheme.Colors.pendingBlue)
                                .disabled(blockingService.hasActiveTasks && !blockingService.isWebsiteBlockingEnabled)
                            }
                            .alert("Blockierung kann nicht deaktiviert werden", isPresented: $showActiveTasksAlert) {
                                Button("OK") { }
                            } message: {
                                Text("Während aktiver Tasks kann die Blockierung nicht deaktiviert werden. Bitte warte, bis alle Tasks abgeschlossen sind.")
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
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                            
                            // Spezifische URL-Blockierung
                            Group {
                                if blockingService.hasActiveTasks {
                                    Button(action: {
                                        showActiveTasksAlert = true
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                                Text("URL-Blockierung (Safari)")
                                                    .font(PremiumTheme.Typography.headlineSM)
                                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                                
                                                Text("Während aktiver Tasks kann die Blockierung nicht geändert werden")
                                                    .font(PremiumTheme.Typography.bodySM)
                                                    .foregroundColor(PremiumTheme.Colors.warning)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(PremiumTheme.Colors.textMuted.opacity(0.5))
                                        }
                                        .padding(PremiumTheme.Spacing.md)
                                        .background(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                                        .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    NavigationLink(destination: URLBlockingView()) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                                Text("URL-Blockierung (Safari)")
                                                    .font(PremiumTheme.Typography.headlineSM)
                                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                                
                                                Text("Blockiere spezifische URLs in Safari")
                                                    .font(PremiumTheme.Typography.bodySM)
                                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                                
                                                if !blockingService.blockedURLs.isEmpty {
                                                    Text("\(blockingService.blockedURLs.count) URL(s) blockiert")
                                                        .font(PremiumTheme.Typography.bodyXS)
                                                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                                        .padding(.top, PremiumTheme.Spacing.xs)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(PremiumTheme.Colors.textMuted)
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
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                        }
                        
                        Divider()
                            .background(PremiumTheme.Colors.borderDefault)
                            .padding(.vertical, PremiumTheme.Spacing.md)
                        
                        // SECTION 3: BLOCKLISTEN
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            Text("Blocklisten")
                                .font(PremiumTheme.Typography.headlineMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .padding(.horizontal, PremiumTheme.Spacing.lg)
                            
                            NavigationLink(destination: BlockListManagementView()) {
                                HStack {
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                        Text("Blocklisten verwalten")
                                            .font(PremiumTheme.Typography.headlineSM)
                                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                                        
                                        Text("Erstelle und verwalte Blocklisten für Apps und URLs. Blocklisten werden automatisch aktiviert, wenn Tasks aktiv sind.")
                                            .font(PremiumTheme.Typography.bodySM)
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                            .lineSpacing(2)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
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
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, PremiumTheme.Spacing.lg)
                        }
                        
                        Divider()
                            .background(PremiumTheme.Colors.borderDefault)
                            .padding(.vertical, PremiumTheme.Spacing.md)
                        
                        // SECTION 4: DESIGN DER BLOCKSEITE
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            Text("Design der Blockseite")
                                .font(PremiumTheme.Typography.headlineMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .padding(.horizontal, PremiumTheme.Spacing.lg)
                            
                            // Block Screen Style Selection
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                Text("Stil")
                                    .font(PremiumTheme.Typography.bodyMD)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: PremiumTheme.Spacing.md) {
                                        ForEach(BlockScreenStyle.allCases, id: \.self) { style in
                                            BlockScreenStyleCard(
                                                style: style,
                                                isSelected: blockingService.blockScreenStyle.style == style,
                                                message: blockingService.blockScreenStyle.displayMessage,
                                                onSelect: {
                                                    let currentBg = BlockScreenBackground(rawValue: blockingService.blockScreenStyle.backgroundImageName ?? "none")
                                                    blockingService.setBlockScreenStyle(style, customMessage: blockingService.blockScreenStyle.customMessage, backgroundImage: currentBg)
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                                }
                            }
                            
                            // Custom Message Input (if custom style selected)
                            if blockingService.blockScreenStyle.style == .custom {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                                    Text("Eigene Nachricht")
                                        .font(PremiumTheme.Typography.bodyMD)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                        
                                    TextField("Nachricht eingeben...", text: Binding(
                                        get: { blockingService.blockScreenStyle.customMessage ?? "" },
                                        set: { newValue in
                                            let currentBg = BlockScreenBackground(rawValue: blockingService.blockScreenStyle.backgroundImageName ?? "none")
                                            blockingService.setBlockScreenStyle(.custom, customMessage: newValue.isEmpty ? nil : newValue, backgroundImage: currentBg)
                                        }
                                    ))
                                    .font(PremiumTheme.Typography.bodyMD)
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
                                .padding(.horizontal, PremiumTheme.Spacing.lg)
                            }
                            
                            // Background Image Selection
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                Text("Hintergrundbild")
                                    .font(PremiumTheme.Typography.bodyMD)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: PremiumTheme.Spacing.sm) {
                                        ForEach(BlockScreenBackground.allCases, id: \.self) { bg in
                                            BackgroundImageButton(
                                                background: bg,
                                                isSelected: blockingService.blockScreenStyle.backgroundImageName == bg.rawValue,
                                                onSelect: {
                                                    blockingService.setBlockScreenStyle(
                                                        blockingService.blockScreenStyle.style,
                                                        customMessage: blockingService.blockScreenStyle.customMessage,
                                                        backgroundImage: bg
                                                    )
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                                }
                            }
                            .padding(.top, PremiumTheme.Spacing.sm)
                        }
                        .padding(.top, PremiumTheme.Spacing.md)
                    }
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                        HStack(spacing: PremiumTheme.Spacing.sm) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(PremiumTheme.Colors.info)
                            
                            Text("Information")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                        }
                        
                        Text("Die Blockierung funktioniert über die Screen Time API von Apple. Apps und Websites werden systemweit blockiert und können während aktiver Tasks nicht geöffnet werden.")
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .lineSpacing(4)
                    }
                    .padding(PremiumTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.xl)
                }
            }
        }
        .onAppear {
            // Lade Standard-Blockliste beim Start
            loadDefaultBlockList()
        }
        .sheet(isPresented: $showAppPicker) {
            CategorizedAppPickerView(
                selectedTokens: Binding(
                    get: { blockingService.familyActivitySelection.applicationTokens },
                    set: { _ in }
                ),
                onSave: { tokens in
                    // Selection is already handled in CategorizedAppPickerView
                    print("📱 BlockingSettingsView: Apps ausgewählt - \(tokens.count) Apps")
                    print("   - BlockingService.familyActivitySelection: \(blockingService.familyActivitySelection.applicationTokens.count) Apps")
                    
                    // Aktualisiere Standard-Blockliste mit den ausgewählten Apps
                    updateDefaultBlockList()
                    
                    // Trigger TaskBlockingMonitor um Blockierung sofort zu aktualisieren
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        TaskBlockingMonitor.shared.checkActiveTasks()
                    }
                }
            )
        }
        .alert("Authorization erforderlich", isPresented: $showAuthorizationAlert) {
            Button("OK") { }
        } message: {
            if let error = authorizationError {
                Text(error)
            } else {
                Text("Screen Time Authorization ist erforderlich, um Apps und Websites zu blockieren.")
            }
        }
    }
    
    private func requestAuthorization() async {
        do {
            try await blockingService.requestAuthorization()
        } catch {
            authorizationError = error.localizedDescription
            showAuthorizationAlert = true
        }
    }
    
    /// Aktualisiert die Standard-Blockliste mit den aktuellen Einstellungen
    private func updateDefaultBlockList() {
        // Hole oder erstelle Standard-Blockliste
        let defaultList: BlockList
        if let existing = blockListRepository.defaultBlockList {
            defaultList = existing
        } else {
            // Erstelle neue Standard-Blockliste
            defaultList = blockListRepository.createBlockList(
                name: "Standard",
                appTokens: blockingService.familyActivitySelection.applicationTokens,
                urls: blockingService.blockedURLs
            )
            blockListRepository.setDefaultBlockList(defaultList)
        }
        
        // Aktualisiere Apps und URLs
        var updatedList = defaultList
        updatedList.appTokens = blockingService.familyActivitySelection.applicationTokens
        updatedList.urls = blockingService.blockedURLs
        updatedList.updatedAt = Date()
        
        // Speichere FamilyActivitySelection für Icon-Anzeige
        blockListRepository.updateBlockListWithSelection(
            updatedList.id,
            selection: blockingService.familyActivitySelection
        )
        
        // Aktualisiere Blockliste
        blockListRepository.updateBlockList(updatedList)
        
        print("✅ BlockingSettingsView: Standard-Blockliste aktualisiert mit \(updatedList.appTokens.count) Apps und \(updatedList.urls.count) URLs")
    }
    
    /// Lädt Standard-Blockliste beim Start
    private func loadDefaultBlockList() {
        print("📖 BlockingSettingsView.loadDefaultBlockList: Start")
        print("   - BlockingService.familyActivitySelection: \(blockingService.familyActivitySelection.applicationTokens.count) Apps")
        
        if let defaultList = blockListRepository.defaultBlockList {
            print("   - Standard-Blockliste gefunden: '\(defaultList.name)'")
            print("   - Blockliste hat \(defaultList.appTokens.count) Apps in appTokens")
            
            // Synchronisiere BlockingService mit Standard-Blockliste
            if let selection = defaultList.loadFamilyActivitySelection() {
                print("   - FamilyActivitySelection aus Blockliste geladen: \(selection.applicationTokens.count) Apps")
                blockingService.familyActivitySelection = selection
                blockingService.blockedAppTokens = selection.applicationTokens
            } else {
                print("   - Keine FamilyActivitySelection in Blockliste gefunden")
                // FALLBACK: Verwende appTokens direkt
                blockingService.blockedAppTokens = defaultList.appTokens
                print("   - Verwende appTokens direkt: \(defaultList.appTokens.count) Apps")
                
                // Versuche FamilyActivitySelection aus UserDefaults zu laden
                if let data = UserDefaults.standard.data(forKey: "blockList_\(defaultList.id)_selection"),
                   let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                    print("   - FamilyActivitySelection aus UserDefaults geladen: \(selection.applicationTokens.count) Apps")
                    blockingService.familyActivitySelection = selection
                    blockingService.blockedAppTokens = selection.applicationTokens
                } else {
                    print("   - Keine FamilyActivitySelection in UserDefaults gefunden")
                    // FALLBACK: Wenn BlockingService bereits Apps hat, verwende diese
                    if !blockingService.familyActivitySelection.applicationTokens.isEmpty {
                        print("   - Fallback: Verwende BlockingService.familyActivitySelection: \(blockingService.familyActivitySelection.applicationTokens.count) Apps")
                        blockingService.blockedAppTokens = blockingService.familyActivitySelection.applicationTokens
                    }
                }
            }
            blockingService.blockedURLs = defaultList.urls
            
            print("✅ BlockingSettingsView: Standard-Blockliste geladen")
            print("   - Final: \(blockingService.blockedAppTokens.count) Apps und \(defaultList.urls.count) URLs")
        } else {
            // Keine Standard-Blockliste vorhanden - lade aus BlockingService
            print("⚠️ BlockingSettingsView: Keine Standard-Blockliste gefunden")
            print("   - Verwende BlockingService.familyActivitySelection: \(blockingService.familyActivitySelection.applicationTokens.count) Apps")
        }
    }
}

// MARK: - Authorization Card

struct AuthorizationCard: View {
    let onRequestAuthorization: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
            HStack(spacing: PremiumTheme.Spacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 24))
                    .foregroundColor(PremiumTheme.Colors.warning)
                
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    Text("Screen Time Authorization erforderlich")
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    Text("Um Apps und Websites zu blockieren, benötigen wir Zugriff auf Screen Time.")
                        .font(PremiumTheme.Typography.bodySM)
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                        .lineSpacing(4)
                }
            }
            
            Button(action: onRequestAuthorization) {
                HStack {
                    Spacer()
                    Text("Authorization anfordern")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, PremiumTheme.Spacing.md)
                .background(
                    LinearGradient(
                        colors: [PremiumTheme.Colors.pendingBlue, PremiumTheme.Colors.pendingBlue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(PremiumTheme.CornerRadius.md)
            }
        }
        .padding(PremiumTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                .fill(PremiumTheme.Colors.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                        .stroke(PremiumTheme.Colors.warning.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

// MARK: - Block Screen Style Card

struct BlockScreenStyleCard: View {
    let style: BlockScreenStyle
    let isSelected: Bool
    let message: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                HStack {
                    Image(systemName: style.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textMuted)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    }
                }
                
                Text(style.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? PremiumTheme.Colors.textPrimary : PremiumTheme.Colors.textSecondary)
                
                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(PremiumTheme.Colors.textMuted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(PremiumTheme.Spacing.md)
            .frame(width: 160, height: 120)
            .background(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                    .fill(isSelected ? PremiumTheme.Colors.pendingBlue.opacity(0.1) : PremiumTheme.Colors.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .stroke(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.borderDefault, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Background Image Button

struct BackgroundImageButton: View {
    let background: BlockScreenBackground
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: PremiumTheme.Spacing.xs) {
                ZStack {
                    // Background Image Preview
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.gray.opacity(0.3),
                                    Color.gray.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                .stroke(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.borderDefault, lineWidth: isSelected ? 2 : 1)
                        )
                    
                    if background != .none {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 24))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                    .background(
                                        Circle()
                                            .fill(PremiumTheme.Colors.backgroundMain)
                                    )
                            }
                            Spacer()
                        }
                        .padding(4)
                    }
                }
                
                Text(background.displayName)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textMuted)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BlockingSettingsView()
}
