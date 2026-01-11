//
//  AppVersion.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Foundation
import Sparkle
import SwiftUI

@Observable
final class AppVersion {

    private let updaterController: SPUStandardUpdaterController

    var isAutoUpdateEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "autoUpdateEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "autoUpdateEnabled")
            updateUpdaterPreferences()
        }
    }

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    init() {
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        if !UserDefaults.standard.bool(forKey: "autoUpdateEnabledSet") {
            UserDefaults.standard.set(true, forKey: "autoUpdateEnabled")
            UserDefaults.standard.set(true, forKey: "autoUpdateEnabledSet")
        }

        updateUpdaterPreferences()
    }

    @MainActor
    func checkForUpdatesManually() {
        updaterController.checkForUpdates(nil)
    }

    func setAutoUpdateEnabled(_ enabled: Bool) {
        isAutoUpdateEnabled = enabled
        AppLogger.main.info("Auto-update \(enabled ? "enabled" : "disabled")")
    }

    private func updateUpdaterPreferences() {
        let updater = updaterController.updater
        updater.automaticallyChecksForUpdates = isAutoUpdateEnabled
        updater.automaticallyDownloadsUpdates = isAutoUpdateEnabled
    }
}
