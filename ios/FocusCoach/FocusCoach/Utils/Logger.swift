//
//  Logger.swift
//  FocusCoach
//
//  Advanced Logging System with Stack Traces and Performance Tracking
//

import Foundation
import os.log
import UIKit

class AppLogger {
    static let shared = AppLogger()
    
    private let logFileURL: URL
    private let crashLogURL: URL
    private let dateFormatter: DateFormatter
    private let logQueue = DispatchQueue(label: "com.focuscoach.logger", qos: .utility)
    private var methodStack: [String] = []
    private let methodStackQueue = DispatchQueue(label: "com.focuscoach.methodstack")
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        logFileURL = documentsPath.appendingPathComponent("focus-coach-debug.log")
        crashLogURL = documentsPath.appendingPathComponent("focus-coach-crash.log")
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        // Log app start with system info
        log("🚀 App Logger initialized", level: .info)
        log("📱 Device: \(UIDevice.current.model) \(UIDevice.current.systemVersion)", level: .info)
        log("💾 Log file: \(logFileURL.path)", level: .info)
    }
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case crash = "CRASH"
    }
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        let thread = Thread.current.isMainThread ? "MAIN" : "BG"
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(thread)] [\(fileName):\(line)] \(function) - \(message)\n"
        
        // Print to console (Xcode will capture this)
        print(logMessage, terminator: "")
        
        // Also use OSLog for system integration
        let osLog = OSLog(subsystem: "com.focuscoach", category: level.rawValue)
        os_log("%{public}@", log: osLog, type: level == .error ? .error : .info, logMessage)
        
        // Write to file asynchronously
        logQueue.async { [weak self] in
            guard let self = self else { return }
            if let data = logMessage.data(using: .utf8) {
                self.writeToFile(data: data, url: self.logFileURL)
            }
        }
    }
    
    private func writeToFile(data: Data, url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            if let fileHandle = try? FileHandle(forWritingTo: url) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: url)
        }
    }
    
    // MARK: - Method Tracing
    
    func traceEnter(_ function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        methodStackQueue.sync {
            methodStack.append("\(fileName):\(line) \(function)")
            let indent = String(repeating: "  ", count: methodStack.count - 1)
            log("\(indent)▶️ ENTER: \(function)", level: .debug, file: file, function: function, line: line)
        }
    }
    
    func traceExit(_ function: String = #function, file: String = #file, line: Int = #line) {
        methodStackQueue.sync {
            if !methodStack.isEmpty {
                let indent = String(repeating: "  ", count: methodStack.count - 1)
                log("\(indent)◀️ EXIT: \(function)", level: .debug, file: file, function: function, line: line)
                methodStack.removeLast()
            }
        }
    }
    
    // MARK: - Stack Trace
    
    func logStackTrace(message: String = "Stack Trace", file: String = #file, function: String = #function, line: Int = #line) {
        let stackSymbols = Thread.callStackSymbols
        var stackTrace = "\(message):\n"
        for (index, symbol) in stackSymbols.enumerated() {
            stackTrace += "  \(index): \(symbol)\n"
        }
        log(stackTrace, level: .debug, file: file, function: function, line: line)
    }
    
    // MARK: - Crash Reporting
    
    func logCrash(reason: String, stackTrace: [String], additionalInfo: [String: Any] = [:]) {
        var crashReport = "\n"
        crashReport += "═══════════════════════════════════════════════════════════\n"
        crashReport += "💥 CRASH REPORT - \(dateFormatter.string(from: Date()))\n"
        crashReport += "═══════════════════════════════════════════════════════════\n"
        crashReport += "Reason: \(reason)\n"
        crashReport += "\nStack Trace:\n"
        for (index, symbol) in stackTrace.enumerated() {
            crashReport += "  \(index): \(symbol)\n"
        }
        crashReport += "\nAdditional Info:\n"
        for (key, value) in additionalInfo {
            crashReport += "  \(key): \(value)\n"
        }
        crashReport += "\nMethod Call Stack:\n"
        methodStackQueue.sync {
            for (index, method) in methodStack.enumerated() {
                crashReport += "  \(index): \(method)\n"
            }
        }
        crashReport += "═══════════════════════════════════════════════════════════\n\n"
        
        if let data = crashReport.data(using: .utf8) {
            logQueue.sync {
                writeToFile(data: data, url: crashLogURL)
                writeToFile(data: data, url: logFileURL)
            }
        }
        
        // Also print to console
        print(crashReport)
    }
    
    func crash(_ message: String, stackTrace: [String] = Thread.callStackSymbols, additionalInfo: [String: Any] = [:], file: String = #file, function: String = #function, line: Int = #line) {
        logCrash(reason: message, stackTrace: stackTrace, additionalInfo: additionalInfo)
        log(message, level: .crash, file: file, function: function, line: line)
    }
    
    // MARK: - Performance Tracking
    
    func measureTime<T>(_ operation: String, file: String = #file, function: String = #function, line: Int = #line, block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        traceEnter("\(function) [\(operation)]", file: file, line: line)
        defer {
            traceExit("\(function) [\(operation)]", file: file, line: line)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            log("⏱️ \(operation) took \(String(format: "%.3f", timeElapsed * 1000))ms", level: .debug, file: file, function: function, line: line)
        }
        return try block()
    }
    
    // MARK: - Convenience Methods
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
        logStackTrace(message: "Error occurred at", file: file, function: function, line: line)
    }
    
    // Get log file path (for Cursor access)
    func getLogFilePath() -> String {
        return logFileURL.path
    }
    
    func getCrashLogPath() -> String {
        return crashLogURL.path
    }
}

// MARK: - Method Tracing Helper

func traceMethod<T>(_ operation: String = "", file: String = #file, function: String = #function, line: Int = #line, block: () throws -> T) rethrows -> T {
    let fullOperation = operation.isEmpty ? function : "\(function) [\(operation)]"
    AppLogger.shared.traceEnter(fullOperation, file: file, line: line)
    defer {
        AppLogger.shared.traceExit(fullOperation, file: file, line: line)
    }
    return try block()
}
