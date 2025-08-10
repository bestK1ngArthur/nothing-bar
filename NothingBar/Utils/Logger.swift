import Foundation
import os

/// Centralized logging system for NothingBar app
struct AppLogger {

    /// Main logger for the application
    static let main = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nothingbar.app", category: "main")

    /// Logger for device-related operations
    static let device = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nothingbar.app", category: "device")

    /// Logger for UI-related operations
    static let ui = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nothingbar.app", category: "ui")

    /// Logger for audio-related operations
    static let audio = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nothingbar.app", category: "audio")

    /// Logger for settings-related operations
    static let settings = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nothingbar.app", category: "settings")

    /// Logger for connection-related operations
    static let connection = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nothingbar.app", category: "connection")
}

/// Convenience extensions for common logging patterns
extension Logger {

    /// Log device discovery
    func deviceDiscovered(_ device: String) {
        self.info("Discovered device: \(device)")
    }

    /// Log connection status
    func connectionChanged(_ connected: Bool, result: String) {
        if connected {
            self.info("Connected: \(result)")
        } else {
            self.info("Disconnected: \(result)")
        }
    }

    /// Log device setting changes
    func deviceSettingChanged(_ setting: String, value: String) {
        self.info("\(setting): \(value)")
    }

    /// Log UI setting changes
    func uiSettingChanged(_ setting: String, value: Any) {
        self.info("\(setting) changed to: \(String(describing: value))")
    }

    /// Log connection errors
    func connectionError(_ error: String) {
        self.error("Connection error: \(error)")
    }

    /// Log general errors
    func logError(_ error: String) {
        self.error("Error: \(error)")
    }
}
