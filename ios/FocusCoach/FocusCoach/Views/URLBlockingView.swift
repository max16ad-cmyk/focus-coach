//
//  URLBlockingView.swift
//  FocusCoach
//
//  UI for managing blocked URLs (Safari Content Blocker)
//

import SwiftUI
import FamilyControls

struct URLBlockingView: View {
    @StateObject private var blockingService = BlockingService.shared
    @StateObject private var blockListRepository = BlockListRepository.shared
    @State private var newURL: String = ""
    @State private var showAddURL = false
    
    private let popularSocialMediaURLs = [
        "youtube.com",
        "instagram.com",
        "facebook.com",
        "twitter.com",
        "tiktok.com",
        "snapchat.com",
        "linkedin.com",
        "pinterest.com",
        "reddit.com",
        "discord.com",
        "twitch.tv",
        "whatsapp.com"
    ]
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: PremiumTheme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("URL-Blockierung")
                            .font(PremiumTheme.Typography.headlineLG)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        Text("Blockiere spezifische Websites in Safari")
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                    
                    // Intelligent Blocking Toggle
                    VStack(spacing: PremiumTheme.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                                HStack(spacing: PremiumTheme.Spacing.sm) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 18))
                                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                    
                                    Text("KI-gestützte Blockierung")
                                        .font(PremiumTheme.Typography.headlineSM)
                                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                                }
                                
                                Text("Analysiert URLs und blockiert nur Unterhaltung, erlaubt Bildung")
                                    .font(PremiumTheme.Typography.bodySM)
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { blockingService.intelligentBlockingEnabled },
                                set: { isOn in
                                    if isOn {
                                        blockingService.enableIntelligentBlocking()
                                    } else {
                                        blockingService.disableIntelligentBlocking()
                                    }
                                }
                            ))
                            .tint(PremiumTheme.Colors.pendingBlue)
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
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    
                    // Info Card
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                        HStack(spacing: PremiumTheme.Spacing.sm) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(PremiumTheme.Colors.info)
                            
                            Text("Hinweis")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                        }
                        
                        Text("Die URL-Blockierung funktioniert nur in Safari. Für andere Browser nutze die allgemeine Website-Blockierung. Mit KI-Blockierung werden nur Unterhaltungsinhalte blockiert, Bildungsinhalte bleiben erlaubt.")
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .lineSpacing(4)
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
                    
                    // Popular Social Media URLs
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Beliebte Social Media Plattformen")
                            .font(PremiumTheme.Typography.headlineSM)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PremiumTheme.Spacing.sm) {
                            ForEach(popularSocialMediaURLs, id: \.self) { url in
                                PopularURLButton(
                                    url: url,
                                    isBlocked: blockingService.blockedURLs.contains(url),
                                    onToggle: {
                                        if blockingService.blockedURLs.contains(url) {
                                            blockingService.removeBlockedURL(url)
                                        } else {
                                            blockingService.addBlockedURL(url)
                                        }
                                        // Aktualisiere Standard-Blockliste
                                        updateDefaultBlockList()
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    
                    // Add URL Button
                    Button(action: { showAddURL = true }) {
                        HStack(spacing: PremiumTheme.Spacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Eigene URL hinzufügen")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
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
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    
                    // Blocked URLs List
                    if blockingService.blockedURLs.isEmpty {
                        VStack(spacing: PremiumTheme.Spacing.md) {
                            Image(systemName: "globe")
                                .font(.system(size: 48))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                            
                            Text("Keine URLs blockiert")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textSecondary)
                            
                            Text("Füge URLs hinzu, die in Safari blockiert werden sollen")
                                .font(PremiumTheme.Typography.bodySM)
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PremiumTheme.Spacing.xxl)
                    } else {
                        VStack(spacing: PremiumTheme.Spacing.sm) {
                            ForEach(blockingService.blockedURLs, id: \.self) { url in
                                URLRow(url: url, onDelete: {
                                    blockingService.removeBlockedURL(url)
                                    // Aktualisiere Standard-Blockliste
                                    updateDefaultBlockList()
                                })
                            }
                        }
                        .padding(.horizontal, PremiumTheme.Spacing.lg)
                    }
                }
            }
        }
        .navigationTitle("URL-Blockierung")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddURL) {
            AddURLSheet(
                url: $newURL,
                onSave: {
                    if !newURL.isEmpty {
                        blockingService.addBlockedURL(newURL)
                        // Aktualisiere Standard-Blockliste
                        updateDefaultBlockList()
                        newURL = ""
                        showAddURL = false
                    }
                },
                onCancel: {
                    newURL = ""
                    showAddURL = false
                }
            )
        }
    }
    
    /// Aktualisiert die Standard-Blockliste mit den aktuellen URLs
    private func updateDefaultBlockList() {
        // Hole oder erstelle Standard-Blockliste
        var defaultList: BlockList
        if let existing = blockListRepository.defaultBlockList {
            defaultList = existing
        } else {
            // Erstelle neue Standard-Blockliste
            defaultList = blockListRepository.createBlockList(
                name: "Standard",
                appTokens: blockingService.familyActivitySelection.applicationTokens,
                urls: blockingService.blockedURLs
            )
            defaultList.isDefault = true
            blockListRepository.setDefaultBlockList(defaultList)
        }
        
        // Aktualisiere URLs
        defaultList.urls = blockingService.blockedURLs
        defaultList.updatedAt = Date()
        defaultList.isDefault = true
        
        // Aktualisiere Blockliste
        blockListRepository.updateBlockList(defaultList)
        
        print("✅ URLBlockingView: Standard-Blockliste aktualisiert mit \(defaultList.urls.count) URLs")
    }
}

// MARK: - URL Row

struct URLRow: View {
    let url: String
    let onDelete: () -> Void
    @StateObject private var blockingService = BlockingService.shared
    @State private var analysisResult: URLAnalysisResult?
    @State private var isAnalyzing = false
    
    var body: some View {
        VStack(spacing: PremiumTheme.Spacing.sm) {
            HStack(spacing: PremiumTheme.Spacing.md) {
                // Icon based on analysis
                if let analysis = analysisResult {
                    Image(systemName: analysis.isEducational ? "book.fill" : "tv.fill")
                        .font(.system(size: 16))
                        .foregroundColor(analysis.isEducational ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.pendingBlue)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                }
                
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    Text(url)
                        .font(PremiumTheme.Typography.bodyMD)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    if let analysis = analysisResult {
                        HStack(spacing: PremiumTheme.Spacing.xs) {
                            Text(analysis.category.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(analysis.isEducational ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.textMuted)
                            
                            if let reason = analysis.reason.split(separator: ".").first {
                                Text("• \(reason)")
                                    .font(.system(size: 11))
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                            }
                        }
                    } else if isAnalyzing {
                        HStack(spacing: PremiumTheme.Spacing.xs) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Analysiere...")
                                .font(.system(size: 11))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(PremiumTheme.Colors.error)
                }
            }
            
            // Analyze button
            if analysisResult == nil && !isAnalyzing {
                Button(action: {
                    analyzeURL()
                }) {
                    HStack(spacing: PremiumTheme.Spacing.xs) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 12))
                        Text("Mit KI analysieren")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .padding(.horizontal, PremiumTheme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PremiumTheme.Colors.pendingBlue.opacity(0.15))
                    )
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
        .onAppear {
            // Load cached analysis if available
            if let cached = blockingService.urlAnalysisCache[url] {
                analysisResult = cached
            }
        }
    }
    
    private func analyzeURL() {
        isAnalyzing = true
        _Concurrency.Task {
            do {
                let analysis: URLAnalysisResult
                if url.contains("youtube.com") || url.contains("youtu.be") {
                    analysis = try await GeminiService.shared.analyzeYouTubeURL(url)
                } else {
                    analysis = try await GeminiService.shared.analyzeURL(url)
                }
                
                await MainActor.run {
                    analysisResult = analysis
                    isAnalyzing = false
                    blockingService.urlAnalysisCache[url] = analysis
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                }
            }
        }
    }
}

// MARK: - Add URL Sheet

struct AddURLSheet: View {
    @Binding var url: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumTheme.Colors.backgroundMain
                    .ignoresSafeArea()
                
                VStack(spacing: PremiumTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                        Text("URL eingeben")
                            .font(PremiumTheme.Typography.bodySM)
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                        
                        TextField("z.B. youtube.com", text: $url)
                            .textFieldStyle(.plain)
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
                            .focused($isFocused)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                        
                        Text("Beispiele: youtube.com, instagram.com, twitter.com")
                            .font(PremiumTheme.Typography.bodyXS)
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    
                    Spacer()
                }
                .padding(.top, PremiumTheme.Spacing.lg)
            }
            .navigationTitle("URL hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: onCancel)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen", action: onSave)
                        .foregroundColor(PremiumTheme.Colors.pendingBlue)
                        .fontWeight(.semibold)
                        .disabled(url.isEmpty)
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - Popular URL Button

struct PopularURLButton: View {
    let url: String
    let isBlocked: Bool
    let onToggle: () -> Void
    
    private var displayName: String {
        url.replacingOccurrences(of: ".com", with: "")
            .replacingOccurrences(of: ".tv", with: "")
            .capitalized
    }
    
    private var icon: String {
        switch url {
        case "youtube.com": return "play.rectangle.fill"
        case "instagram.com": return "camera.fill"
        case "facebook.com": return "f.circle.fill"
        case "twitter.com": return "at"
        case "tiktok.com": return "music.note"
        case "snapchat.com": return "camera.fill"
        case "linkedin.com": return "briefcase.fill"
        case "pinterest.com": return "pin.fill"
        case "reddit.com": return "r.circle.fill"
        case "discord.com": return "message.fill"
        case "twitch.tv": return "play.circle.fill"
        case "whatsapp.com": return "message.fill"
        default: return "globe"
        }
    }
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: PremiumTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isBlocked ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.textMuted)
                
                Text(displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isBlocked ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                if isBlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(PremiumTheme.Colors.productivityGreen)
                }
            }
            .padding(PremiumTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                    .fill(isBlocked ? PremiumTheme.Colors.productivityGreen.opacity(0.15) : PremiumTheme.Colors.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                            .stroke(isBlocked ? PremiumTheme.Colors.productivityGreen : PremiumTheme.Colors.borderDefault, lineWidth: isBlocked ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    URLBlockingView()
}

