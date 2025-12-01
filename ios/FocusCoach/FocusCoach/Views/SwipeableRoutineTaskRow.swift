//
//  SwipeableRoutineTaskRow.swift
//  FocusCoach
//
//  Swipeable Routine Task Row mit Swipe-to-Delete und Edit
//

import SwiftUI

struct SwipeableRoutineTaskRow: View {
    let task: RoutineTask
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDeleting = false
    
    private let deleteThreshold: CGFloat = -100
    private let buttonWidth: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Action Buttons Background
            if dragOffset < 0 {
                HStack(spacing: 0) {
                    Spacer()
                    
                    // Edit Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onEdit()
                        }
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: 60)
                            .background(Color.blue)
                    }
                    
                    // Delete Button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isDeleting = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onDelete()
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: 60)
                            .background(Color.red)
                    }
                }
            }
            
            // Task Row
            RoutineTaskRow(task: task)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            // Nur nach links swipen erlauben
                            if value.translation.width < 0 {
                                // Maximal 2 Buttons breit
                                dragOffset = max(value.translation.width, -buttonWidth * 2)
                            }
                        }
                        .onEnded { value in
                            if value.translation.width < deleteThreshold {
                                // Swipe weit genug - zeige Buttons
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    dragOffset = -buttonWidth * 2
                                }
                            } else {
                                // Zurück zur Ausgangsposition
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            if dragOffset == 0 {
                                onEdit()
                            } else {
                                // Zurück zur Ausgangsposition wenn geklickt wird
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
        }
        .opacity(isDeleting ? 0 : 1)
        .scaleEffect(isDeleting ? 0.8 : 1.0)
    }
}

