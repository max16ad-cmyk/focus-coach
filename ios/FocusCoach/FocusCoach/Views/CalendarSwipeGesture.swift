//
//  CalendarSwipeGesture.swift
//  FocusCoach
//
//  Verbesserte Swipe-Geste für Kalender mit kontinuierlichem Swipe über Monatsgrenzen
//

import SwiftUI

struct CalendarSwipeGesture: ViewModifier {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var startDate: Date = Date()
    @State private var lastUpdateDate: Date = Date()
    
    private let calendar = Calendar.current
    private let swipeThreshold: CGFloat = 15
    private let updateInterval: TimeInterval = 0.03 // Update alle 30ms für sehr flüssiges Swipen
    private let pixelsPerDay: CGFloat = 40 // ~40px pro Tag für Berechnung
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            startDate = selectedDate
                            lastUpdateDate = Date()
                        }
                        
                        // Kontinuierliches Update während des Swipens
                        let now = Date()
                        if now.timeIntervalSince(lastUpdateDate) >= updateInterval {
                            updateDateDuringDrag(translation: value.translation.width)
                            lastUpdateDate = now
                        }
                        
                        // Visuelles Feedback während des Swipens (optional)
                        dragOffset = value.translation.width * 0.2
                    }
                    .onEnded { value in
                        isDragging = false
                        dragOffset = 0
                        
                        let threshold: CGFloat = swipeThreshold
                        let velocity = value.predictedEndTranslation.width - value.translation.width
                        
                        // Berechne finale Anzahl der Tage basierend auf Swipe-Distanz
                        let swipeDistance = abs(value.translation.width)
                        let baseDays = max(1, Int(swipeDistance / pixelsPerDay))
                        
                        // Berücksichtige Geschwindigkeit für schnelles Swipen
                        let velocityMultiplier = min(abs(velocity) / 400, 4.0) // Max 4x Multiplikator
                        let daysToMove = Int(Double(baseDays) * (1.0 + velocityMultiplier))
                        
                        // Finale Bewegung mit Animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85, blendDuration: 0.1)) {
                            if value.translation.width > threshold || velocity > 80 {
                                // Swipe right - vorherige Tage
                                moveDate(by: -daysToMove, from: startDate)
                            } else if value.translation.width < -threshold || velocity < -80 {
                                // Swipe left - nächste Tage
                                moveDate(by: daysToMove, from: startDate)
                            }
                        }
                    }
            )
    }
    
    /// Aktualisiert das Datum während des Swipens (kontinuierlich)
    private func updateDateDuringDrag(translation: CGFloat) {
        // Berechne Tage basierend auf Swipe-Distanz
        let daysToMove = Int(translation / pixelsPerDay)
        
        // Verwende startDate als Basis, nicht selectedDate (verhindert Akkumulation)
        if let newDate = calendar.date(byAdding: .day, value: daysToMove, to: startDate) {
            // Update selectedDate ohne Animation für flüssiges Swipen
            selectedDate = newDate
            
            // Update currentMonth wenn Monatsgrenze überschritten
            updateCurrentMonthIfNeeded(for: newDate)
        }
    }
    
    /// Bewegt das Datum um eine bestimmte Anzahl von Tagen von einem Startdatum aus
    private func moveDate(by days: Int, from start: Date) {
        guard let newDate = calendar.date(byAdding: .day, value: days, to: start) else { return }
        
        selectedDate = newDate
        updateCurrentMonthIfNeeded(for: newDate)
    }
    
    /// Aktualisiert currentMonth wenn das neue Datum in einem anderen Monat liegt
    private func updateCurrentMonthIfNeeded(for date: Date) {
        let newMonth = calendar.component(.month, from: date)
        let newYear = calendar.component(.year, from: date)
        let currentMonthComponent = calendar.component(.month, from: currentMonth)
        let currentYearComponent = calendar.component(.year, from: currentMonth)
        
        if newMonth != currentMonthComponent || newYear != currentYearComponent {
            // Monatsgrenze überschritten - aktualisiere currentMonth
            if let updatedMonth = calendar.date(from: DateComponents(year: newYear, month: newMonth, day: 1)) {
                currentMonth = updatedMonth
            }
        }
    }
}

extension View {
    func calendarSwipeGesture(selectedDate: Binding<Date>, currentMonth: Binding<Date>) -> some View {
        modifier(CalendarSwipeGesture(selectedDate: selectedDate, currentMonth: currentMonth))
    }
}

