//
//  TaskBlock.swift
//  FocusCoach
//
//  Block-basierte Task-Komponente mit Drag & Drop
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskBlock: View {
    let task: Task
    let allTasks: [Task] // Alle Tasks für Sub-Task-Lookup
    let level: Int // Verschachtelungs-Level (0 = Top-Level)
    let taskRepository: TaskRepository // Für Hierarchie-Operationen
    let isDragging: Bool // Wird von außen gesteuert
    let dropTarget: Bool // Ist dieser Block das Drop-Target?
    let dropPosition: DropPosition? // Position des Drop-Targets
    let onToggle: () -> Void
    let onTap: () -> Void
    let onDragStart: () -> Void
    let onDragEnd: () -> Void
    let onDrop: ((String, DropPosition) -> Void)? // (taskId, position)
    
    enum DropPosition {
        case above
        case inside
        case below
    }
    
    @State private var dragOffset: CGSize = .zero
    @State private var isExpanded = true // Sub-Tasks expanded/collapsed
    @State private var isHovered = false
    
    // Berechne Sub-Tasks für diesen Task
    private var subTasks: [Task] {
        taskRepository.getSubTasks(for: task.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Drop-Zone Indikator oben
            if dropTarget && dropPosition == .above {
                Rectangle()
                    .fill(PremiumTheme.Colors.pendingBlue.opacity(0.5))
                    .frame(height: 3)
                    .padding(.horizontal, PremiumTheme.Spacing.md)
            }
            
            // Haupt-Task Block
            HStack(spacing: PremiumTheme.Spacing.md) {
                // Drag Handle (nur für Top-Level Tasks)
                if level == 0 {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.textMuted)
                        .padding(.trailing, PremiumTheme.Spacing.xs)
                }
                
                // Indentation für Sub-Tasks
                if level > 0 {
                    Rectangle()
                        .fill(PremiumTheme.Colors.borderDefault)
                        .frame(width: 2)
                        .padding(.trailing, PremiumTheme.Spacing.sm)
                }
                
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(task.completed ? .green : PremiumTheme.Colors.textMuted)
                }
                
                // Task Content
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    // Title
                    Text(task.title)
                        .font(.system(size: 16, weight: task.completed ? .regular : .medium))
                        .foregroundColor(task.completed ? PremiumTheme.Colors.textMuted : PremiumTheme.Colors.textPrimary)
                        .strikethrough(task.completed)
                    
                    // Time & Category
                    HStack(spacing: PremiumTheme.Spacing.sm) {
                        if let startTime = task.scheduledStartTime, let endTime = task.scheduledEndTime {
                            Text("\(startTime) - \(endTime)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                        }
                        
                        if let category = task.category {
                            Text(category.rawValue)
                                .font(.system(size: 11))
                                .foregroundColor(PremiumTheme.Colors.pendingBlue)
                                .padding(.horizontal, PremiumTheme.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(PremiumTheme.Colors.pendingBlue.opacity(0.1))
                                )
                        }
                        
                        if task.hasSubTasks {
                            Text("\(subTasks.count)")
                                .font(.system(size: 11))
                                .foregroundColor(PremiumTheme.Colors.textMuted)
                                .padding(.horizontal, PremiumTheme.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(PremiumTheme.Colors.backgroundCard)
                                )
                        }
                    }
                    
                    // Notes (wenn vorhanden)
                    if let notes = task.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 13))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .lineLimit(2)
                            .padding(.top, PremiumTheme.Spacing.xs)
                    }
                }
                
                Spacer()
                
                // Expand/Collapse Button (nur wenn Sub-Tasks vorhanden)
                if task.hasSubTasks {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                }
            }
            .padding(.horizontal, PremiumTheme.Spacing.md)
            .padding(.vertical, PremiumTheme.Spacing.sm)
            .background(
                ZStack {
                    // Drop-Zone Highlight
                    if dropTarget && dropPosition == .inside {
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(PremiumTheme.Colors.pendingBlue.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .stroke(PremiumTheme.Colors.pendingBlue, lineWidth: 2)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                            .fill(task.completed ? PremiumTheme.Colors.backgroundCard.opacity(0.5) : PremiumTheme.Colors.backgroundCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.md)
                                    .stroke(
                                        level == 0 ? PremiumTheme.Colors.borderDefault : PremiumTheme.Colors.borderDefault.opacity(0.5),
                                        lineWidth: level == 0 ? 1 : 0.5
                                    )
                            )
                    }
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .offset(dragOffset)
            .opacity(isDragging ? 0.6 : 1.0)
            .gesture(
                level == 0 ? DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if dragOffset == .zero {
                            onDragStart()
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        dragOffset = .zero
                        onDragEnd()
                    } : nil
            )
            .onDrop(of: [.text], isTargeted: $isHovered) { providers in
                guard let provider = providers.first else { return false }
                
                var droppedTaskId: String?
                let semaphore = DispatchSemaphore(value: 0)
                
                provider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, error in
                    if let data = data as? Data,
                       let taskId = String(data: data, encoding: .utf8) {
                        droppedTaskId = taskId
                    }
                    semaphore.signal()
                }
                
                semaphore.wait()
                
                if let taskId = droppedTaskId, taskId != task.id {
                    // Bestimme Drop-Position basierend auf Drop-Location
                    // Für jetzt: immer "below" (kann später verfeinert werden)
                    DispatchQueue.main.async {
                        onDrop?(taskId, .below)
                    }
                    return true
                }
                
                return false
            }
            .onDrag {
                // Erstelle NSItemProvider mit Task ID als String
                let provider = NSItemProvider()
                provider.registerDataRepresentation(forTypeIdentifier: "public.text", visibility: .all) { completion in
                    let data = task.id.data(using: .utf8) ?? Data()
                    completion(data, nil)
                    return nil
                }
                return provider
            }
            
            // Drop-Zone Indikator unten
            if dropTarget && dropPosition == .below {
                Rectangle()
                    .fill(PremiumTheme.Colors.pendingBlue.opacity(0.5))
                    .frame(height: 3)
                    .padding(.horizontal, PremiumTheme.Spacing.md)
            }
            
            // Sub-Tasks (wenn expanded)
            if isExpanded && task.hasSubTasks {
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    ForEach(subTasks) { subTask in
                        TaskBlock(
                            task: subTask,
                            allTasks: allTasks,
                            level: level + 1,
                            taskRepository: taskRepository,
                            isDragging: false,
                            dropTarget: false,
                            dropPosition: nil,
                            onToggle: {
                                _Concurrency.Task {
                                    do {
                                        try await taskRepository.toggleTaskCompletion(subTask)
                                    } catch {
                                        print("⚠️ Fehler beim Toggle von Sub-Task: \(error)")
                                    }
                                }
                            },
                            onTap: {
                                onTap() // Verwende gleiche Tap-Action
                            },
                            onDragStart: {},
                            onDragEnd: {},
                            onDrop: onDrop
                        )
                    }
                }
                .padding(.leading, PremiumTheme.Spacing.lg)
                .padding(.top, PremiumTheme.Spacing.xs)
            }
        }
    }
}

#Preview {
    VStack {
        TaskBlock(
            task: Task(
                id: "main",
                title: "Website-Projekt",
                subTaskIds: ["sub1", "sub2"],
                order: 0
            ),
            allTasks: [
                Task(id: "sub1", title: "Design erstellen", parentTaskId: "main", order: 0),
                Task(id: "sub2", title: "Code schreiben", parentTaskId: "main", order: 1)
            ],
            level: 0,
            taskRepository: TaskRepository.shared,
            isDragging: false,
            dropTarget: false,
            dropPosition: nil,
            onToggle: {},
            onTap: {},
            onDragStart: {},
            onDragEnd: {},
            onDrop: nil
        )
    }
    .padding()
    .background(PremiumTheme.Colors.backgroundMain)
}
