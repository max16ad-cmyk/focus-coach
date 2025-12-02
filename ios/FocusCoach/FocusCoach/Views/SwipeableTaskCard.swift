//
//  SwipeableTaskCard.swift
//  FocusCoach
//
//  Swipeable Task Card mit Swipe-to-Delete für wiederkehrende Aufgaben
//

import SwiftUI

struct SwipeableTaskCard: View {
    let task: Task
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
            
            // Task Card
            RecurringTaskCard(task: task)
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

struct RecurringTaskCard: View {
    let task: Task
    
    private var repeatPatternText: String {
        switch task.repeatPattern {
        case .daily:
            return "Täglich"
        case .weekly:
            if let weekdays = task.repeatWeekdays, !weekdays.displayText.isEmpty {
                return weekdays.displayText
            }
            return "Wöchentlich"
        case .monthly:
            return "Monatlich"
        case .weekdays:
            if let weekdays = task.repeatWeekdays, !weekdays.displayText.isEmpty {
                return weekdays.displayText
            }
            return "Wochentage"
        case .none:
            return ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PremiumTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: PremiumTheme.Spacing.xs) {
                    Text(task.title)
                        .font(PremiumTheme.Typography.headlineSM)
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                    
                    if let startTime = task.scheduledStartTime, let endTime = task.scheduledEndTime {
                        Text("\(startTime) - \(endTime)")
                            .font(.system(size: 13))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                    
                    HStack(spacing: PremiumTheme.Spacing.md) {
                        Label(repeatPatternText, systemImage: "repeat")
                            .font(.system(size: 12))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                    }
                }
                
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




