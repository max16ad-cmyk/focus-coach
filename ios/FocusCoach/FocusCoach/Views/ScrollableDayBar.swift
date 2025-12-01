//
//  ScrollableDayBar.swift
//  FocusCoach
//
//  Scrollbare Tag-Leiste mit durchgehender Rolle von Tagen
//

import SwiftUI

struct ScrollableDayBar: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    @State private var visibleDates: [Date] = []
    @State private var centeredDate: Date? = nil // Tag der gerade in der Mitte ist
    @State private var scrollTimer: Timer? = nil // Timer für kontinuierliches Tracking während des Scrollens
    @State private var isScrolling = false
    
    private let calendar = Calendar.current
    private let daysToLoad = 60 // Lade 60 Tage vor und nach dem aktuellen Datum
    private let dayButtonWidth: CGFloat = 50 // Breite eines DayButtons
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    private let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(visibleDates, id: \.self) { date in
                            DayButton(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isToday: calendar.isDateInToday(date),
                                dayFormatter: dayFormatter,
                                dayNumberFormatter: dayNumberFormatter,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedDate = date
                                        updateCurrentMonthIfNeeded(for: date)
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            proxy.scrollTo(date, anchor: UnitPoint.center)
                                        }
                                    }
                                }
                            )
                            .id(date)
                            .background(
                                GeometryReader { buttonGeometry in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetPreferenceKey.self,
                                            value: [ScrollOffsetData(
                                                date: date,
                                                minX: buttonGeometry.frame(in: .named("scroll")).minX,
                                                centerX: buttonGeometry.frame(in: .named("scroll")).midX
                                            )]
                                        )
                                }
                            )
                        }
                    }
                    .padding(.horizontal, PremiumTheme.Spacing.md)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offsets in
                    updateCenteredDate(from: offsets, screenWidth: geometry.size.width)
                }
                // Tracke Scroll-Gesten für kontinuierliches Updates
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            // Während des Scrollens wird onPreferenceChange kontinuierlich aufgerufen
                            isScrolling = true
                        }
                        .onEnded { _ in
                            isScrolling = false
                        }
                )
                .onAppear {
                    // WICHTIG: Stelle IMMER sicher, dass selectedDate auf heute gesetzt ist
                    let today = Date()
                    let todayStartOfDay = calendar.startOfDay(for: today)
                    
                    // Setze selectedDate auf heute, wenn es nicht bereits heute ist
                    if !calendar.isDate(selectedDate, inSameDayAs: today) {
                        selectedDate = todayStartOfDay
                    }
                    
                    // Initialisiere mit HEUTE als Zentrum (nicht selectedDate, falls das falsch ist)
                    initializeDates(around: todayStartOfDay)
                    centeredDate = todayStartOfDay
                    updateCurrentMonthIfNeeded(for: todayStartOfDay)
                    
                    // WICHTIG: Warte bis die View vollständig gerendert ist UND visibleDates geladen sind
                    // Verwende mehrere Versuche mit unterschiedlichen Delays
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        // Prüfe ob today in visibleDates ist
                        if visibleDates.contains(where: { calendar.isDate($0, inSameDayAs: todayStartOfDay) }) {
                            // Scroll zu today mit Animation - CENTER anchor für Mitte
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(todayStartOfDay, anchor: UnitPoint.center)
                            }
                            print("✅ ScrollableDayBar: Gescrollt zu heute (Index 1)")
                        } else {
                            print("⚠️ ScrollableDayBar: Heute nicht in visibleDates, lade mehr Tage...")
                            initializeDates(around: todayStartOfDay)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo(todayStartOfDay, anchor: UnitPoint.center)
                                }
                            }
                        }
                    }
                    
                    // Zusätzlicher Versuch nach 0.8 Sekunden für maximale Zuverlässigkeit
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if visibleDates.contains(where: { calendar.isDate($0, inSameDayAs: todayStartOfDay) }) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(todayStartOfDay, anchor: UnitPoint.center)
                            }
                            print("✅ ScrollableDayBar: Zweiter Scroll-Versuch zu heute")
                        }
                    }
                    
                    // Finaler Versuch nach 1.5 Sekunden
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if visibleDates.contains(where: { calendar.isDate($0, inSameDayAs: todayStartOfDay) }) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(todayStartOfDay, anchor: UnitPoint.center)
                            }
                            print("✅ ScrollableDayBar: Finaler Scroll-Versuch zu heute")
                        }
                    }
                }
                .onChange(of: selectedDate) { newDate in
                    // Lade mehr Tage wenn nötig
                    loadMoreDaysIfNeeded(around: newDate)
                    // Aktualisiere Monat beim Datumswechsel
                    updateCurrentMonthIfNeeded(for: newDate)
                    centeredDate = newDate
                    
                    // Scroll zu neuem Datum, aber nur wenn es in visibleDates ist
                    if visibleDates.contains(where: { calendar.isDate($0, inSameDayAs: newDate) }) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            proxy.scrollTo(newDate, anchor: UnitPoint.center)
                        }
                    } else {
                        // Falls nicht, lade mehr Tage und scroll dann
                        initializeDates(around: newDate)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                proxy.scrollTo(newDate, anchor: UnitPoint.center)
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            // Swipe-Geste für Tag-für-Tag Navigation
                            let threshold: CGFloat = 30
                            let velocity = value.predictedEndTranslation.width - value.translation.width
                            
                            if abs(value.translation.width) > threshold || abs(velocity) > 100 {
                                let direction = value.translation.width > 0 ? -1 : 1
                                
                                if let newDate = calendar.date(byAdding: .day, value: direction, to: selectedDate) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedDate = newDate
                                        updateCurrentMonthIfNeeded(for: newDate)
                                        loadMoreDaysIfNeeded(around: newDate)
                                        proxy.scrollTo(newDate, anchor: UnitPoint.center)
                                    }
                                }
                            }
                        }
                )
            }
        }
    }
    
    /// Initialisiert die sichtbaren Daten
    private func initializeDates(around date: Date? = nil) {
        let baseDate = date ?? selectedDate // Verwende selectedDate statt today
        var dates: [Date] = []
        
        // WICHTIG: Stelle sicher, dass baseDate in der MITTE der Liste ist
        // Erstelle Liste von Tagen (60 Tage vor bis 60 Tage nach baseDate)
        // So dass baseDate in der Mitte steht (Index ~60)
        for i in -daysToLoad...daysToLoad {
            if let date = calendar.date(byAdding: .day, value: i, to: baseDate) {
                dates.append(date)
            }
        }
        
        visibleDates = dates
        
        // Debug: Prüfe ob baseDate wirklich in der Liste ist
        if let baseDateIndex = dates.firstIndex(where: { calendar.isDate($0, inSameDayAs: baseDate) }) {
            print("📅 ScrollableDayBar: baseDate '\(baseDate)' ist an Index \(baseDateIndex) von \(dates.count) (Mitte wäre ~\(dates.count/2))")
        } else {
            print("⚠️ ScrollableDayBar: baseDate '\(baseDate)' NICHT in visibleDates gefunden!")
        }
    }
    
    /// Lädt mehr Tage wenn nötig
    private func loadMoreDaysIfNeeded(around date: Date) {
        guard let firstDate = visibleDates.first,
              let lastDate = visibleDates.last else { return }
        
        let daysFromStart = calendar.dateComponents([.day], from: firstDate, to: date).day ?? 0
        let daysFromEnd = calendar.dateComponents([.day], from: date, to: lastDate).day ?? 0
        
        // Wenn weniger als 10 Tage vom Rand entfernt, lade mehr
        if daysFromStart < 10 {
            loadDaysBefore(firstDate)
        }
        if daysFromEnd < 10 {
            loadDaysAfter(lastDate)
        }
    }
    
    /// Lädt Tage vor dem ersten sichtbaren Datum
    private func loadDaysBefore(_ firstDate: Date) {
        var newDates: [Date] = []
        for i in 1...30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: firstDate) {
                newDates.insert(date, at: 0)
            }
        }
        visibleDates.insert(contentsOf: newDates, at: 0)
    }
    
    /// Lädt Tage nach dem letzten sichtbaren Datum
    private func loadDaysAfter(_ lastDate: Date) {
        var newDates: [Date] = []
        for i in 1...30 {
            if let date = calendar.date(byAdding: .day, value: i, to: lastDate) {
                newDates.append(date)
            }
        }
        visibleDates.append(contentsOf: newDates)
    }
    
    
    /// Findet den zentrierten Tag und aktualisiert currentMonth
    private func updateCenteredDate(from offsets: [ScrollOffsetData], screenWidth: CGFloat) {
        let screenCenter = screenWidth / 2
        
        // Finde das Datum, dessen Center am nächsten zur Bildschirmmitte ist
        var closestDate: Date?
        var minDistance: CGFloat = .infinity
        
        for offset in offsets {
            // Prüfe ob der Button sichtbar ist (innerhalb des Viewports)
            if offset.minX >= -dayButtonWidth && offset.minX <= screenWidth {
                let distance = abs(offset.centerX - screenCenter)
                if distance < minDistance {
                    minDistance = distance
                    closestDate = offset.date
                }
            }
        }
        
        // Aktualisiere centeredDate und currentMonth wenn sich der zentrierte Tag ändert
        if let closest = closestDate, !calendar.isDate(closest, inSameDayAs: centeredDate ?? Date.distantPast) {
            centeredDate = closest
            // Aktualisiere currentMonth basierend auf dem zentrierten Tag
            updateCurrentMonthIfNeeded(for: closest)
        }
    }
    
    /// Startet kontinuierliches Tracking während des Scrollens
    private func startScrollTracking(geometry: GeometryProxy) {
        scrollTimer?.invalidate()
        // Der Timer ist nicht nötig, da onPreferenceChange während des Scrollens
        // kontinuierlich aufgerufen wird. Wir markieren nur, dass wir scrollen.
    }
    
    /// Stoppt das Scroll-Tracking
    private func stopScrollTracking() {
        scrollTimer?.invalidate()
        scrollTimer = nil
        isScrolling = false
    }
    
    /// Aktualisiert currentMonth wenn das neue Datum in einem anderen Monat liegt
    private func updateCurrentMonthIfNeeded(for date: Date) {
        let newMonth = calendar.component(.month, from: date)
        let newYear = calendar.component(.year, from: date)
        let currentMonthComponent = calendar.component(.month, from: currentMonth)
        let currentYearComponent = calendar.component(.year, from: currentMonth)
        
        if newMonth != currentMonthComponent || newYear != currentYearComponent {
            if let updatedMonth = calendar.date(from: DateComponents(year: newYear, month: newMonth, day: 1)) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    currentMonth = updatedMonth
                }
            }
        }
    }
}

// MARK: - Preference Key für Scroll-Position Tracking

struct ScrollOffsetData: Equatable {
    let date: Date
    let minX: CGFloat
    let centerX: CGFloat
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [ScrollOffsetData] = []
    
    static func reduce(value: inout [ScrollOffsetData], nextValue: () -> [ScrollOffsetData]) {
        value.append(contentsOf: nextValue())
    }
}

struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let dayFormatter: DateFormatter
    let dayNumberFormatter: DateFormatter
    
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: PremiumTheme.Spacing.xs) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? PremiumTheme.Colors.pendingBlue : PremiumTheme.Colors.textSecondary)
                
                Text(dayNumberFormatter.string(from: date))
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(
                        isSelected ? PremiumTheme.Colors.pendingBlue :
                        isToday ? PremiumTheme.Colors.pendingBlue :
                        PremiumTheme.Colors.textPrimary
                    )
            }
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.sm)
                    .fill(isSelected ? PremiumTheme.Colors.pendingBlue.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

