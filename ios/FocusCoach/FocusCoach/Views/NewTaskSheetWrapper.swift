//
//  NewTaskSheetWrapper.swift
//  FocusCoach
//
//  Wrapper für NewTaskSheet mit State Management
//

import SwiftUI

struct NewTaskSheetWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskRepository = TaskRepository.shared
    
    @State private var taskText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var repeatPattern: RepeatPattern? = nil
    @State private var repeatWeekdays: RepeatWeekdays? = nil
    @State private var initialStartTime: String? = nil
    @State private var initialEndTime: String? = nil
    @State private var initialNotes: String? = nil
    @State private var selectedBlockListId: String? = nil
    
    var body: some View {
        NewTaskSheet(
            taskText: $taskText,
            selectedDate: $selectedDate,
            repeatPattern: $repeatPattern,
            repeatWeekdays: $repeatWeekdays,
            initialStartTime: initialStartTime,
            initialEndTime: initialEndTime,
            initialNotes: initialNotes,
            onSave: { startTime, endTime, date, repeatPattern, repeatWeekdays, notes, blockListId in
                // Create task
                let task = Task(
                    id: UUID().uuidString,
                    title: taskText,
                    completed: false,
                    createdAt: Int64(Date().timeIntervalSince1970 * 1000),
                    scheduledDate: dateString(from: date),
                    scheduledStartTime: startTime,
                    scheduledEndTime: endTime,
                    repeatPattern: repeatPattern,
                    repeatWeekdays: repeatWeekdays,
                    notes: notes,
                    blockListId: blockListId
                )
                
                _Concurrency.Task {
                    do {
                        try await taskRepository.saveTask(task)
                    } catch {
                        print("⚠️ Fehler beim Speichern der Aufgabe: \(error)")
                    }
                }
                
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

