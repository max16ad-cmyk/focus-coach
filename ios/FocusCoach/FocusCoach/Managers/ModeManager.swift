//
//  ModeManager.swift
//  FocusCoach
//
//  Mode Management - Determines current app mode based on time, settings, and day plan
//

import Foundation
import Combine

class ModeManager: ObservableObject {
    // Empty ObservableObject - just for protocol conformance
    
    func getCurrentMode(
        settings: UserSettings,
        dayPlan: DayPlan?,
        userOverride: DashboardViewMode? = nil
    ) -> DashboardViewMode {
        // User override takes precedence
        if let override = userOverride {
            return override
        }
        
        // Auto mode based on time and plan
        return getAutoMode(settings: settings, dayPlan: dayPlan)
    }
    
    private func getAutoMode(settings: UserSettings, dayPlan: DayPlan?) -> DashboardViewMode {
        let now = Date()
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: now)
        let minutes = calendar.component(.minute, from: now)
        let currentMinutes = hours * 60 + minutes
        
        // 1. Night Mode Check (Highest Priority)
        if settings.nightModeEnabled {
            let nightStart = parseTime(settings.nightModeStart)
            let nightEnd = parseTime(settings.nightModeEnd)
            
            let isNightTime: Bool
            if nightStart > nightEnd {
                // Overnight (e.g., 23:00 - 06:00)
                isNightTime = currentMinutes >= nightStart || currentMinutes < nightEnd
            } else {
                // Same day (e.g., 22:00 - 23:00)
                isNightTime = currentMinutes >= nightStart && currentMinutes < nightEnd
            }
            
            if isNightTime {
                return .night
            }
        }
        
        // 2. Morning Lock Check (if no plan)
        if settings.morningLockEnabled && dayPlan == nil {
            let morningStart = parseTime(settings.morningLockStart)
            let morningEnd = parseTime(settings.morningLockEnd)
            
            if currentMinutes >= morningStart && currentMinutes < morningEnd {
                return .createPlan // Force to create plan
            }
        }
        
        // 3. Plan-based modes
        guard let plan = dayPlan else {
            return .overview
        }
        
        // Plan exists but not confirmed
        if !plan.confirmed {
            return .createPlan
        }
        
        // All tasks completed → Freedom Mode
        let allCompleted = plan.tasks.allSatisfy { $0.completed }
        if allCompleted {
            return .freedom
        }
        
        // Default: Active Day
        return .activeDay
    }
    
    func canNavigateTo(_ targetMode: DashboardViewMode, autoMode: DashboardViewMode, settings: UserSettings) -> Bool {
        // Night Mode blocks everything (except settings)
        if autoMode == .night && settings.nightModeNoUnlock {
            return false
        }
        
        // Freedom can only be reached automatically
        if targetMode == .freedom {
            return false
        }
        
        // Verification can only be reached from active-day
        if targetMode == .verification {
            return autoMode == .activeDay
        }
        
        // All other modes are freely navigable
        return true
    }
    
    private func parseTime(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return 0
        }
        return hours * 60 + minutes
    }
}

