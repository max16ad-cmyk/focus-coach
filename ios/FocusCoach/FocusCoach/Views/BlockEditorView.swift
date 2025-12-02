//
//  BlockEditorView.swift
//  FocusCoach
//
//  Block-basierter Editor für Tasks mit Sub-Task-Unterstützung
//

import SwiftUI

struct BlockEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskRepository = TaskRepository.shared
    
    let task: Task
    
    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var hasTimeSlot: Bool = false
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var subTasks: [Task] = []
    @State private var showingAddSubTask = false
    
    var body: some View {
        NavigationView {
            ZStack {
                PremiumTheme.Colors.backgroundMain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: PremiumTheme.Spacing.lg) {
                        // Title
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Titel")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            TextField("Aufgaben-Titel", text: $title)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .autocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .textInputAutocapitalization(.sentences)
                                .keyboardType(.default)
                                .submitLabel(.next)
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
                        
                        // Time Slot Toggle
                        Toggle("Zeit festlegen", isOn: $hasTimeSlot)
                            .font(PremiumTheme.Typography.bodyMD)
                            .foregroundColor(PremiumTheme.Colors.textPrimary)
                        
                        if hasTimeSlot {
                            HStack(spacing: PremiumTheme.Spacing.md) {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    Text("Von")
                                        .font(.system(size: 12))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(PremiumTheme.Colors.pendingBlue)
                                }
                                
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    Text("Bis")
                                        .font(.system(size: 12))
                                        .foregroundColor(PremiumTheme.Colors.textMuted)
                                    
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(PremiumTheme.Colors.pendingBlue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .fill(PremiumTheme.Colors.backgroundCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                            .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                            Text("Notizen (optional)")
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                            
                            TextField("Notizen", text: $notes, axis: .vertical)
                                .font(PremiumTheme.Typography.bodyMD)
                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                .autocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                                .textInputAutocapitalization(.sentences)
                                .keyboardType(.default)
                                .submitLabel(.done)
                                .lineLimit(3...6)
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
                        
                        // Sub-Tasks Section
                        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.md) {
                            HStack {
                                Text("Sub-Tasks")
                                    .font(PremiumTheme.Typography.bodyMD)
                                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAddSubTask = true
                                }) {
                                    HStack(spacing: PremiumTheme.Spacing.xs) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Hinzufügen")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                }
                            }
                            
                            if subTasks.isEmpty {
                                Text("Keine Sub-Tasks")
                                    .font(.system(size: 13))
                                    .foregroundColor(PremiumTheme.Colors.textMuted)
                                    .padding(.vertical, PremiumTheme.Spacing.md)
                            } else {
                                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
                                    ForEach(subTasks) { subTask in
                                        HStack {
                                            Text(subTask.title)
                                                .font(.system(size: 14))
                                                .foregroundColor(PremiumTheme.Colors.textPrimary)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                deleteSubTask(subTask)
                                            }) {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(.horizontal, PremiumTheme.Spacing.md)
                                        .padding(.vertical, PremiumTheme.Spacing.sm)
                                        .background(
                                            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                                .fill(PremiumTheme.Colors.backgroundCard)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                                                        .stroke(PremiumTheme.Colors.borderDefault.opacity(0.5), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.lg)
                    .padding(.top, PremiumTheme.Spacing.lg)
                }
            }
            .navigationTitle("Task bearbeiten")
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
                        saveTask()
                    }
                    .foregroundColor(PremiumTheme.Colors.pendingBlue)
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty || isSaving)
                }
            }
            .sheet(isPresented: $showingAddSubTask) {
                AddSubTaskSheet(
                    parentTaskId: task.id,
                    onSave: { subTaskTitle in
                        addSubTask(title: subTaskTitle)
                    }
                )
            }
            .onAppear {
                loadTaskData()
            }
        }
    }
    
    private func loadTaskData() {
        title = task.title
        notes = task.notes ?? ""
        
        // Parse Datum und Zeit
        if let scheduledDateString = task.scheduledDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: scheduledDateString) {
                selectedDate = date
            }
        }
        
        hasTimeSlot = task.hasTimeSlot
        if let startTimeStr = task.scheduledStartTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            if let date = formatter.date(from: startTimeStr) {
                startTime = date
            }
        }
        if let endTimeStr = task.scheduledEndTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            if let date = formatter.date(from: endTimeStr) {
                endTime = date
            }
        }
        
        // Lade Sub-Tasks
        subTasks = taskRepository.getSubTasks(for: task.id)
    }
    
    private func saveTask() {
        guard !isSaving else { return }
        
        isSaving = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let scheduledDateString = dateFormatter.string(from: selectedDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let startTimeString = hasTimeSlot ? timeFormatter.string(from: startTime) : nil
        let endTimeString = hasTimeSlot ? timeFormatter.string(from: endTime) : nil
        
        var updatedTask = task
        updatedTask.title = title.trimmingCharacters(in: .whitespaces)
        updatedTask.scheduledDate = scheduledDateString
        updatedTask.scheduledStartTime = startTimeString
        updatedTask.scheduledEndTime = endTimeString
        updatedTask.notes = notes.isEmpty ? nil : notes
        
        _Concurrency.Task {
            do {
                try await taskRepository.updateTask(updatedTask)
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    print("❌ Fehler beim Speichern: \(error)")
                }
            }
        }
    }
    
    private func addSubTask(title: String) {
        let newSubTask = Task(
            id: UUID().uuidString,
            title: title,
            completed: false,
            createdAt: Int64(Date().timeIntervalSince1970 * 1000),
            parentTaskId: task.id,
            order: subTasks.count
        )
        
        _Concurrency.Task {
            do {
                try await taskRepository.addSubTask(to: task.id, task: newSubTask)
                await MainActor.run {
                    subTasks = taskRepository.getSubTasks(for: task.id)
                }
            } catch {
                print("❌ Fehler beim Hinzufügen von Sub-Task: \(error)")
            }
        }
    }
    
    private func deleteSubTask(_ subTask: Task) {
        _Concurrency.Task {
            do {
                try await taskRepository.removeSubTask(from: task.id, taskId: subTask.id)
                await MainActor.run {
                    subTasks = taskRepository.getSubTasks(for: task.id)
                }
            } catch {
                print("❌ Fehler beim Löschen von Sub-Task: \(error)")
            }
        }
    }
}

struct AddSubTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let parentTaskId: String
    let onSave: (String) -> Void
    
    @State private var title: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: PremiumTheme.Spacing.lg) {
                TextField("Sub-Task Titel", text: $title)
                    .font(PremiumTheme.Typography.bodyMD)
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                    .autocapitalization(.sentences)
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
                    .padding(.top, PremiumTheme.Spacing.lg)
                
                Spacer()
            }
            .navigationTitle("Sub-Task hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        onSave(title)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}




