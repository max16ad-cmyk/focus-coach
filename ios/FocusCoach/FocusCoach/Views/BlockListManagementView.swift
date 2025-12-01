//
//  BlockListManagementView.swift
//  FocusCoach
//
//  View für Verwaltung von Blocklisten
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct BlockListManagementView: View {
    @StateObject private var blockListRepository = BlockListRepository.shared
    @StateObject private var blockingService = BlockingService.shared
    @StateObject private var screenTimeAnalyzer = ScreenTimeAnalyzer.shared
    @State private var showingCreateBlockList = false
    @State private var editingBlockList: BlockList?
    @State private var showingScreenTimeAnalysis = false
    @State private var showingPersonalizedBlockList = false
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: PremiumTheme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Blocklisten")
                            .font(PremiumTheme.Typography.headlineLG)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        Text("Verwalte deine Blocklisten für Apps und Websites")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    
                    // Personalisierte Blockliste erstellen (Bildschirmzeit-Analyse)
                    if #available(iOS 15.0, *) {
                        Button(action: {
                            showingScreenTimeAnalysis = true
                        }) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                    Text("Meine Zeitfresser analysieren")
                                        .font(PremiumTheme.Typography.bodyMD)
                                        .fontWeight(.semibold)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    Text("Analysiere deine Bildschirmzeit und erstelle eine personalisierte Blockliste")
                                        .font(.system(size: 12))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                            }
                            .padding(PremiumTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(PremiumTheme.Colors.backgroundCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        PremiumTheme.Colors.pendingBlue.opacity(0.5),
                                                        PremiumTheme.Colors.pendingBlue.opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                    
                    // Create Button
                    Button(action: {
                        showingCreateBlockList = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Neue Blockliste erstellen")
                                .font(PremiumTheme.Typography.bodyMD)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(PremiumTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            PremiumTheme.Colors.pendingBlue,
                                            PremiumTheme.Colors.pendingBlue.opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    
                    // Block Lists
                    if blockListRepository.blockLists.isEmpty {
                        VStack(spacing: PremiumTheme.Spacing.md) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 48))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                            
                            Text("Noch keine Blocklisten")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textSecondary)
                            
                            Text("Erstelle eine Blockliste, um Apps und Websites zu organisieren")
                                .font(PremiumTheme.Typography.bodySM)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(PremiumTheme.Spacing.xl)
                    } else {
                        VStack(spacing: PremiumTheme.Spacing.md) {
                            ForEach(blockListRepository.blockLists) { blockList in
                                BlockListCard(
                                    blockList: blockList,
                                    isDefault: blockList.id == blockListRepository.defaultBlockList?.id,
                                    onEdit: {
                                        editingBlockList = blockList
                                    },
                                    onDelete: {
                                        blockListRepository.deleteBlockList(blockList)
                                    },
                                    onSetDefault: {
                                        blockListRepository.setDefaultBlockList(blockList)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                }
                .padding(.bottom, PremiumTheme.Spacing.xl)
            }
        }
        .navigationTitle("Blocklisten")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCreateBlockList) {
            BlockListEditView(blockList: nil) { blockList in
                _ = blockListRepository.createBlockList(
                    name: blockList.name,
                    appTokens: blockList.appTokens,
                    urls: blockList.urls
                )
            }
        }
        .sheet(item: $editingBlockList) { blockList in
            BlockListEditView(blockList: blockList) { updatedBlockList in
                blockListRepository.updateBlockList(updatedBlockList)
            }
        }
        .sheet(isPresented: $showingScreenTimeAnalysis) {
            ScreenTimeAnalysisView(
                onComplete: { selectedTokens, summary in
                    // Erstelle personalisierte Blockliste
                    let personalizedList = screenTimeAnalyzer.createPersonalizedBlockList(
                        from: selectedTokens,
                        name: "Meine Zeitfresser"
                    )
                    _ = blockListRepository.createBlockList(
                        name: personalizedList.name,
                        appTokens: personalizedList.appTokens,
                        urls: personalizedList.urls
                    )
                    showingScreenTimeAnalysis = false
                },
                onCancel: {
                    showingScreenTimeAnalysis = false
                }
            )
        }
    }
}

struct BlockListCard: View {
    let blockList: BlockList
    let isDefault: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    HStack(spacing: PremiumTheme.Spacing.sm) {
                        Text(blockList.name)
                            .font(PremiumTheme.Typography.headlineSM)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        if isDefault {
                            Text("STANDARD")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                .padding(.horizontal, PremiumTheme.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(PremiumTheme.Colors.pendingBlue.opacity(0.2))
                                )
                        }
                    }
                    
                    HStack(spacing: PremiumTheme.Spacing.md) {
                        Label("\(blockList.appTokens.count) App(s)", systemImage: "app.badge")
                            .font(.system(size: 12))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                        
                        Label("\(blockList.urls.count) URL(s)", systemImage: "link")
                            .font(.system(size: 12))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(action: onEdit) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    
                    if !isDefault {
                        Button(action: onSetDefault) {
                            Label("Als Standard setzen", systemImage: "star")
                        }
                    }
                    
                    Divider()
                    
                    if !isDefault {
                        Button(role: .destructive, action: onDelete) {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                        .padding(8)
                }
            }
        }
        .padding(PremiumTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                .fill(PremiumTheme.Colors.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                        .stroke(isDefault ? PremiumTheme.Colors.pendingBlue.opacity(0.5) : PremiumTheme.Colors.borderDefault, lineWidth: isDefault ? 2 : 1)
                )
        )
    }
}

struct BlockListEditView: View {
    let blockList: BlockList?
    let onSave: (BlockList) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var urls: [String] = []
    @State private var newURL: String = ""
    @State private var urlSuggestions: [String] = []
    @State private var showingAppPicker = false
    @State private var selectedTokens: Set<ApplicationToken> = []
    @State private var familyActivitySelection = FamilyActivitySelection()
    @StateObject private var blockListRepository = BlockListRepository.shared
    @State private var isStandardBlockList = false
    
    init(blockList: BlockList?, onSave: @escaping (BlockList) -> Void) {
        self.blockList = blockList
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumTheme.Colors.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        // Name
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Name")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            TextField("Blocklisten-Name", text: $name)
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
                        .padding(.top, PremiumTheme.Spacing.lg)
                        
                        // Apps
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            HStack {
                                Text("Apps")
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
                            
                            // Info für Standard-Blocklisten ohne Apps
                            if isStandardBlockList && selectedTokens.isEmpty && !urls.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                        Text("Standard-Blockliste")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    }
                                    Text("Diese Blockliste enthält bereits vorkonfigurierte URLs. Wähle Apps aus, um die Blockliste zu vervollständigen.")
                                        .font(.system(size: 11))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                        .lineSpacing(2)
                                }
                                .padding(PremiumTheme.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                        .fill(PremiumTheme.Colors.pendingBlue.opacity(0.1))
                                )
                            }
                            
                            // Ausgewählte Apps anzeigen mit echten Icons
                            if !selectedTokens.isEmpty {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    Text("Ausgewählte Apps:")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    // Zeige App-Icons über FamilyActivitySelection
                                    // Die Selection enthält die Icons, die wir anzeigen können
                                    if !familyActivitySelection.applicationTokens.isEmpty && familyActivitySelection.applicationTokens.count == selectedTokens.count {
                                        // Verwende FamilyActivitySelection für Icon-Anzeige
                                        FamilyActivitySelectionView(selection: familyActivitySelection)
                                            .frame(minHeight: 120)
                                    } else if !selectedTokens.isEmpty {
                                        // Fallback: Zeige kompakte Liste mit App-Platzhaltern
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
                        
                        // URLs
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            Text("URLs")
                                .font(PremiumTheme.Typography.headlineSM)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            // Add URL mit Vorschlägen
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                HStack(spacing: PremiumTheme.Spacing.sm) {
                                    TextField("z.B. youtube oder youtube.com", text: $newURL)
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
                                        .onChange(of: newURL) { newValue in
                                            // Update suggestions when typing
                                            if !newValue.isEmpty {
                                                urlSuggestions = URLSuggestions.searchSuggestions(for: newValue)
                                            } else {
                                                urlSuggestions = Array(URLSuggestions.popularDomains.values).sorted().prefix(5).map { $0 }
                                            }
                                        }
                                    
                                    Button(action: {
                                        addURL()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                    }
                                }
                                
                                // URL-Vorschläge
                                if !urlSuggestions.isEmpty && !newURL.isEmpty {
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                        Text("Vorschläge:")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                        
                                        ForEach(urlSuggestions.prefix(5), id: \.self) { suggestion in
                                            Button(action: {
                                                newURL = suggestion
                                                addURL()
                                            }) {
                                                HStack {
                                                    Image(systemName: "link")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                                    
                                                    Text(suggestion)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "arrow.up.left")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                                }
                                                .padding(PremiumTheme.Spacing.sm)
                                                .background(
                                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                                        .fill(PremiumTheme.Colors.backgroundCard.opacity(0.5))
                                                )
                                            }
                                        }
                                    }
                                    .padding(.top, PremiumTheme.Spacing.xs)
                                } else if newURL.isEmpty {
                                    // Beliebte URLs anzeigen wenn Feld leer
                                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                        Text("Beliebte Websites:")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(PremiumTheme.Colors.textMuted)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: PremiumTheme.Spacing.sm) {
                                                ForEach(Array(URLSuggestions.popularDomains.values).sorted().prefix(8), id: \.self) { domain in
                                                    Button(action: {
                                                        newURL = domain
                                                        addURL()
                                                    }) {
                                                        Text(domain)
                                                            .font(.system(size: 12))
                                                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                                                            .padding(.horizontal, PremiumTheme.Spacing.sm)
                                                            .padding(.vertical, PremiumTheme.Spacing.xs)
                                                            .background(
                                                                Capsule()
                                                                    .fill(PremiumTheme.Colors.backgroundCard)
                                                            )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, PremiumTheme.Spacing.xs)
                                }
                            }
                            
                            // URL List
                            if !urls.isEmpty {
                                VStack(spacing: PremiumTheme.Spacing.sm) {
                                    ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                                        HStack {
                                            Text(url)
                                                .font(.system(size: 14))
                                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                urls.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(PremiumTheme.Colors.error)
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
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                    .padding(.bottom, PremiumTheme.Spacing.xl)
                }
            }
            .navigationTitle(blockList == nil ? "Neue Blockliste" : "Blockliste bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        // Speichere FamilyActivitySelection für Icon-Anzeige
                        let selectionData: Data?
                        do {
                            let encoder = JSONEncoder()
                            selectionData = try encoder.encode(familyActivitySelection)
                        } catch {
                            print("⚠️ Fehler beim Speichern der Selection: \(error)")
                            selectionData = nil
                        }
                        
                        let updatedBlockList = BlockList(
                            id: blockList?.id ?? UUID().uuidString,
                            name: name,
                            appTokens: selectedTokens,
                            urls: urls,
                            createdAt: blockList?.createdAt ?? Date(),
                            updatedAt: Date(),
                            isDefault: blockList?.isDefault ?? false,
                            familyActivitySelectionData: selectionData
                        )
                        
                        // Speichere auch über Repository für schnellen Zugriff
                        blockListRepository.updateBlockListWithSelection(
                            updatedBlockList.id,
                            selection: familyActivitySelection
                        )
                        
                        onSave(updatedBlockList)
                        dismiss()
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            if let blockList = blockList {
                name = blockList.name
                urls = blockList.urls
                
                // Prüfe ob es eine Standard-Blockliste ist
                isStandardBlockList = blockList.id.hasPrefix("standard-") || blockList.id.hasPrefix("personalized-")
                
                // Lade FamilyActivitySelection für Icon-Anzeige
                if let selection = blockList.loadFamilyActivitySelection() {
                    familyActivitySelection = selection
                    selectedTokens = selection.applicationTokens
                } else {
                    // Versuche Selection aus UserDefaults zu laden
                    if let data = UserDefaults.standard.data(forKey: "blockList_\(blockList.id)_selection"),
                       let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
                        familyActivitySelection = selection
                        selectedTokens = selection.applicationTokens
                    } else {
                        // Fallback: Verwende appTokens direkt
                        selectedTokens = blockList.appTokens
                        // Erstelle eine minimale FamilyActivitySelection für Icon-Anzeige
                        // (wird beim Speichern aktualisiert)
                    }
                }
                
                print("📖 BlockListEditView: Lade Blockliste '\(blockList.name)' mit \(selectedTokens.count) Apps")
            }
            
            // Initial suggestions
            urlSuggestions = Array(URLSuggestions.popularDomains.values).sorted().prefix(5).map { $0 }
        }
        .onChange(of: showingAppPicker) { isShowing in
            if !isShowing {
                // Update familyActivitySelection nach App-Picker
                familyActivitySelection = BlockingService.shared.familyActivitySelection
            }
        }
        .sheet(isPresented: $showingAppPicker) {
            CategorizedAppPickerView(
                selectedTokens: $selectedTokens,
                onSave: { tokens in
                    selectedTokens = tokens
                    // Update familyActivitySelection für Icon-Anzeige
                    // Die Selection wird vom CategorizedAppPickerView aktualisiert
                    familyActivitySelection = BlockingService.shared.familyActivitySelection
                }
            )
        }
    }
    
    // Helper function to add URL
    private func addURL() {
        let trimmedURL = newURL.trimmingCharacters(in: .whitespaces)
        guard !trimmedURL.isEmpty else { return }
        
        // Normalize URL
        let normalizedURL = URLSuggestions.normalizeURL(trimmedURL)
        
        // Check if already exists
        if !urls.contains(normalizedURL) {
            urls.append(normalizedURL)
        }
        
        newURL = ""
        urlSuggestions = []
    }
}

