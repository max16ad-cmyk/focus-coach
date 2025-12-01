//
//  FocusCoachApp.swift
//  FocusCoach
//
//  Main App Entry Point
//

import SwiftUI
import Foundation

// Global signal handler functions (must be C-compatible, no captures)
private func handleSignal(_ signalNumber: Int32) {
    let stackTrace = Thread.callStackSymbols
    let signalNames: [Int32: String] = [
        SIGABRT: "SIGABRT",
        SIGILL: "SIGILL",
        SIGSEGV: "SIGSEGV",
        SIGFPE: "SIGFPE",
        SIGBUS: "SIGBUS",
        SIGPIPE: "SIGPIPE"
    ]
    let name = signalNames[signalNumber] ?? "UNKNOWN"
    AppLogger.shared.crash(
        "\(name) received (signal \(signalNumber))",
        stackTrace: stackTrace,
        additionalInfo: [
            "signal": "\(signalNumber)",
            "signalName": name
        ]
    )
    exit(1)
}

@main
struct FocusCoachApp: App {
    @StateObject private var firebaseService = FirebaseService.shared
    
    init() {
        AppLogger.shared.traceEnter("FocusCoachApp.init")
        defer { AppLogger.shared.traceExit("FocusCoachApp.init") }
        
        // Setup crash handler FIRST
        setupCrashHandler()
        
        AppLogger.shared.info("📱 FocusCoachApp.init() - Starting initialization")
        
        // Configure Firebase immediately - simple and direct
        FirebaseService.shared.configure()
        
        AppLogger.shared.info("📱 FocusCoachApp.init() - Initialization complete")
    }
    
    private func setupCrashHandler() {
        AppLogger.shared.info("🛡️ Setting up crash handlers")
        
        // Log uncaught exceptions
        NSSetUncaughtExceptionHandler { exception in
            let reason = exception.reason ?? "Unknown"
            let stackTrace = exception.callStackSymbols
            let userInfo = exception.userInfo ?? [:]
            
            AppLogger.shared.crash(
                "Uncaught Exception: \(reason)",
                stackTrace: stackTrace,
                additionalInfo: [
                    "name": exception.name.rawValue,
                    "userInfo": "\(userInfo)"
                ]
            )
        }
        
        // Setup signal handlers
        signal(SIGABRT, handleSignal)
        signal(SIGILL, handleSignal)
        signal(SIGSEGV, handleSignal)
        signal(SIGFPE, handleSignal)
        signal(SIGBUS, handleSignal)
        signal(SIGPIPE, handleSignal)
        
        AppLogger.shared.info("✅ Crash handlers setup complete")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseService)
                .preferredColorScheme(.dark)
        }
    }
}
