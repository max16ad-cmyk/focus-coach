//
//  NotizenView.swift
//  FocusCoach
//
//  Tab 3: NOTIZEN - Notes with optional checklists
//

import SwiftUI

struct NotizenView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var notes: [Note] = []
    @State private var searchText = ""
    @State private var selectedCategory: NoteCategory? = nil
    @State private var showingNewNote = false
    
    private var filteredNotes: [Note] {
        var filtered = notes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Sortierung: Neueste zuerst (nach updatedAt, falls vorhanden, sonst createdAt)
        filtered.sort { note1, note2 in
            let date1 = note1.updatedAt > 0 ? note1.updatedAt : note1.createdAt
            let date2 = note2.updatedAt > 0 ? note2.updatedAt : note2.createdAt
            return date1 > date2
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            PremiumTheme.Colors.backgroundMain
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                    
                    TextField("Suchen", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                        .fill(PremiumTheme.Colors.backgroundCard)
                )
                .padding(.horizontal, PremiumTheme.Spacing.lg)
                .padding(.top, PremiumTheme.Spacing.md)
                
                // Categories (optional - can be hidden later)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PremiumTheme.Spacing.sm) {
                        CategoryChip(
                            title: "Alle",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach([NoteCategory.allgemein, .arbeit, .privat, .ideen], id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                }
                .padding(.top, PremiumTheme.Spacing.md)
                
                Divider()
                    .background(PremiumTheme.Colors.borderDefault)
                    .padding(.top, PremiumTheme.Spacing.md)
                
                // Notes List - ScrollView starts at top
                ScrollView {
                    VStack(spacing: 0) {
                        if filteredNotes.isEmpty {
                            VStack(spacing: PremiumTheme.Spacing.md) {
                                Text("Keine Notizen")
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.textSecondary)
                                    .padding(.top, PremiumTheme.Spacing.xxl)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, PremiumTheme.Spacing.xxl)
                        } else {
                            ForEach(filteredNotes) { note in
                                NoteRow(note: note)
                                
                                Divider()
                                    .background(PremiumTheme.Colors.borderDefault)
                            }
                        }
                        
                        // Bottom padding for FAB
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
            
            // Floating Action Buttons - + and Microphone
            VStack {
                Spacer()
                HStack(spacing: PremiumTheme.Spacing.md) {
                    Spacer()
                    
                    // Voice Input Button for Notes
                    VoiceInputButtonForNotes { transcribedText in
                        // Create note from transcribed text
                        let note = Note(
                            title: transcribedText.components(separatedBy: ".").first?.trimmingCharacters(in: .whitespaces) ?? "Neue Notiz",
                            content: transcribedText,
                            category: nil,
                            createdAt: Int64(Date().timeIntervalSince1970 * 1000),
                            updatedAt: Int64(Date().timeIntervalSince1970 * 1000)
                        )
                        notes.append(note)
                        saveNotes()
                    }
                    .padding(.trailing, PremiumTheme.Spacing.sm)
                    
                    // Add Note Button
                    Button(action: { showingNewNote = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.25),
                                                        Color.white.opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.4),
                                                        Color.white.opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                            )
                    }
                    .padding(.trailing, PremiumTheme.Spacing.lg)
                    .padding(.bottom, PremiumTheme.Spacing.lg)
                }
            }
        }
        .onAppear {
            loadNotes()
        }
        .sheet(isPresented: $showingNewNote) {
            NewNoteSheet(onSave: { note in
                notes.append(note)
                saveNotes()
                showingNewNote = false
            }, onCancel: {
                showingNewNote = false
            })
        }
    }
    
    private func loadNotes() {
        // Load notes from Firebase or UserDefaults
        // TODO: Implement
    }
    
    private func saveNotes() {
        // Save notes to Firebase
        // TODO: Implement
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? PremiumTheme.Colors.ralphLaurenBlue : PremiumTheme.Colors.textSecondary)
                .padding(.horizontal, PremiumTheme.Spacing.md)
                .padding(.vertical, PremiumTheme.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                        .fill(isSelected ? PremiumTheme.Colors.ralphLaurenBlue.opacity(0.1) : PremiumTheme.Colors.backgroundCard)
                )
        }
    }
}

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        NavigationLink(destination: NoteDetailView(note: note)) {
            HStack(spacing: PremiumTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    Text(note.title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.system(size: 14))
                            .foregroundColor(PremiumTheme.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    if let checklist = note.checklist, !checklist.isEmpty {
                        HStack(spacing: PremiumTheme.Spacing.xs) {
                            Image(systemName: "checklist")
                                .font(.system(size: 12))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                            Text("\(checklist.filter { $0.completed }.count)/\(checklist.count)")
                                .font(.system(size: 12))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, PremiumTheme.Spacing.lg)
            .padding(.vertical, PremiumTheme.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoteDetailView: View {
    @State var note: Note
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PremiumTheme.Spacing.lg) {
                TextField("Titel", text: $note.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                
                TextEditor(text: $note.content)
                    .frame(minHeight: 200)
                    .font(.system(size: 16))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                
                // Checklist (optional - only when opened)
                if let checklist = note.checklist, !checklist.isEmpty {
                    VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                        Text("Checkliste")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        ForEach(checklist) { item in
                            HStack {
                                Button(action: { 
                                    if let index = note.checklist?.firstIndex(where: { $0.id == item.id }) {
                                        note.checklist?[index].completed.toggle()
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .stroke(item.completed ? PremiumTheme.Colors.ralphLaurenBlue : PremiumTheme.Colors.textMuted, lineWidth: 2)
                                            .frame(width: 20, height: 20)
                                        
                                        if item.completed {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(PremiumTheme.Colors.ralphLaurenBlue)
                                        }
                                    }
                                }
                                
                                Text(item.text)
                                    .font(.system(size: 16))
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                    .strikethrough(item.completed)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(PremiumTheme.Colors.backgroundMain)
        .navigationTitle("Notiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NewNoteSheet: View {
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory: NoteCategory? = nil
    let onSave: (Note) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: PremiumTheme.Spacing.lg) {
                TextField("Titel", text: $title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                
                TextEditor(text: $content)
                    .frame(minHeight: 200)
                    .font(.system(size: 16))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.backgroundCard)
                    )
                
                Spacer()
            }
            .padding()
            .background(PremiumTheme.Colors.backgroundMain)
            .navigationTitle("Neue Notiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen", action: onCancel)
                        .foregroundColor(PremiumTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        let note = Note(
                            title: title.isEmpty ? "Neue Notiz" : title,
                            content: content,
                            category: selectedCategory
                        )
                        onSave(note)
                    }
                    .foregroundColor(PremiumTheme.Colors.ralphLaurenBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

