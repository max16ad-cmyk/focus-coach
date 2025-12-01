//
//  ExpandedCalendarView.swift
//  FocusCoach
//
//  Expanded Calendar View for PlanungView
//

import SwiftUI

struct ExpandedCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    private let calendar = Calendar.current
    
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    private var displayedMonthYear: String {
        Self.monthYearFormatter.string(from: currentMonth)
    }
    
    private func monthDates(for month: Date) -> [Date] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let firstWeekday = calendar.dateInterval(of: .weekOfYear, for: firstDayOfMonth)?.start else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate: Date? = firstWeekday
        
        // Add dates until we have 6 weeks (42 days) to fill the calendar
        while dates.count < 42, let date = currentDate {
            dates.append(date)
            currentDate = calendar.date(byAdding: .day, value: 1, to: date)
        }
        
        return dates
    }
    
    private var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.shortWeekdaySymbols
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month/Year Header mit Navigation
            HStack {
                Button(action: {
                    if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            currentMonth = previousMonth
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
                
                Spacer()
                
                Text(displayedMonthYear)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(PremiumTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            currentMonth = nextMonth
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(PremiumTheme.Colors.textPrimary)
                }
            }
            .padding(.horizontal, PremiumTheme.Spacing.md)
            .padding(.vertical, PremiumTheme.Spacing.sm)
            
            // Calendar Grid - nur ein Monat
            VStack(spacing: PremiumTheme.Spacing.md) {
                // Weekday Headers
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { weekday in
                        Text(weekday)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(PremiumTheme.Colors.textMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: PremiumTheme.Spacing.xs) {
                    ForEach(monthDates(for: currentMonth), id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            isToday: calendar.isDateInToday(date),
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                    // Update currentMonth wenn nötig
                                    if !calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                                        if let newMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) {
                                            currentMonth = newMonth
                                        }
                                    }
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, PremiumTheme.Spacing.md)
            .padding(.vertical, PremiumTheme.Spacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                .fill(PremiumTheme.Colors.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: PremiumTheme.CornerRadius.lg)
                        .stroke(PremiumTheme.Colors.borderDefault, lineWidth: 1)
                )
        )
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                if isSelected {
                    Circle()
                        .fill(PremiumTheme.Colors.pendingBlue)
                        .scaleEffect(isSelected ? 1.0 : 0.8)
                } else if isToday {
                    Circle()
                        .fill(PremiumTheme.Colors.pendingBlue.opacity(0.2))
                } else {
                    Circle()
                        .fill(Color.clear)
                }
                
                // Day Number
                Text(dayNumber)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(
                        isSelected ? .white :
                        isToday ? PremiumTheme.Colors.pendingBlue :
                        isCurrentMonth ? PremiumTheme.Colors.textPrimary :
                        PremiumTheme.Colors.textMuted
                    )
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ExpandedCalendarView(
        selectedDate: .constant(Date()),
        currentMonth: .constant(Date())
    )
    .padding()
    .background(PremiumTheme.Colors.backgroundMain)
}

