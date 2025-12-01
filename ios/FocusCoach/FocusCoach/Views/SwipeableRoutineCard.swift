//
//  SwipeableRoutineCard.swift
//  FocusCoach
//
//  Swipeable Routine Card mit Swipe-to-Delete
//

import SwiftUI

struct SwipeableRoutineCard: View {
    let routine: Routine
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDeleting = false
    
    private let deleteThreshold: CGFloat = -100
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete Button Background
            if dragOffset < 0 {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isDeleting = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onDelete()
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.red)
                    }
                }
            }
            
            // Routine Card
            RoutineCard(routine: routine)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            // Nur nach links swipen erlauben
                            if value.translation.width < 0 {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            if value.translation.width < deleteThreshold {
                                // Swipe weit genug - zeige Delete Button
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    dragOffset = -80
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
                                onTap()
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

