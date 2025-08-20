//
//  AppVersion.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Foundation
import SwiftUI
import AppUpdater

@Observable
class AppVersion {

    private var appUpdater: AppUpdater
    private var updateCheckTimer: Timer?

    var isAutoUpdateEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "autoUpdateEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "autoUpdateEnabled")
            if newValue {
                startPeriodicUpdateCheck()
            } else {
                stopPeriodicUpdateCheck()
            }
        }
    }

    private var lastUpdateCheck: Date {
        get { UserDefaults.standard.object(forKey: "lastUpdateCheck") as? Date ?? Date.distantPast }
        set { UserDefaults.standard.set(newValue, forKey: "lastUpdateCheck") }
    }

    var isCheckingForUpdates = false

    var updateAvailable: Bool {
        return appUpdater.downloadedAppBundle != nil
    }

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    init() {
        self.appUpdater = AppUpdater(owner: "bestK1ngArthur", repo: "nothing-bar")

        if !UserDefaults.standard.bool(forKey: "autoUpdateEnabledSet") {
            UserDefaults.standard.set(true, forKey: "autoUpdateEnabled")
            UserDefaults.standard.set(true, forKey: "autoUpdateEnabledSet")
        }

        if isAutoUpdateEnabled {
            startPeriodicUpdateCheck()
        }
    }

    deinit {
        stopPeriodicUpdateCheck()
    }

    private func startPeriodicUpdateCheck() {
        guard isAutoUpdateEnabled else { return }

        stopPeriodicUpdateCheck()

        updateCheckTimer = Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkForUpdatesInBackground()
            }
        }

        let timeSinceLastCheck = Date().timeIntervalSince(lastUpdateCheck)
        if timeSinceLastCheck > 24 * 60 * 60 {
            Task { @MainActor in
                await checkForUpdatesInBackground()
            }
        }
    }

    private func stopPeriodicUpdateCheck() {
        updateCheckTimer?.invalidate()
        updateCheckTimer = nil
    }

    @MainActor
    func checkForUpdatesInBackground() async {
        guard isAutoUpdateEnabled else { return }

        isCheckingForUpdates = true
        lastUpdateCheck = Date()

        appUpdater.check(
            { [weak self] in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isCheckingForUpdates = false

                    if let downloadedBundle = self.appUpdater.downloadedAppBundle {
                        AppLogger.main.info("Update available, installing automatically...")
                        self.appUpdater.install(downloadedBundle,
                            {
                                AppLogger.main.info("Update installed successfully")
                            },
                            { error in
                                AppLogger.main.logError("Failed to install update: \(error)")
                            }
                        )
                    } else {
                        AppLogger.main.info("No updates available")
                    }
                }
            },
            { [weak self] error in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isCheckingForUpdates = false
                    AppLogger.main.logError("Failed to check for updates: \(error)")
                }
            }
        )
    }

    @MainActor
    func checkForUpdatesManually() async {
        isCheckingForUpdates = true

        appUpdater.check(
            { [weak self] in
                // Success callback
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isCheckingForUpdates = false

                    if self.appUpdater.downloadedAppBundle != nil {
                        AppLogger.main.info("Manual update check: Update available")
                    } else {
                        AppLogger.main.info("Manual update check: No updates available")
                    }
                }
            },
            { [weak self] error in
                // Failure callback
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isCheckingForUpdates = false
                    AppLogger.main.logError("Manual update check failed: \(error)")
                }
            }
        )
    }

    @MainActor
    func installUpdate() async {
        guard let downloadedBundle = appUpdater.downloadedAppBundle else { return }

        appUpdater.install(downloadedBundle,
            {
                AppLogger.main.info("Update installed successfully")
            },
            { error in
                AppLogger.main.logError("Failed to install update: \(error)")
            }
        )
    }

    func setAutoUpdateEnabled(_ enabled: Bool) {
        isAutoUpdateEnabled = enabled
        AppLogger.main.info("Auto-update \(enabled ? "enabled" : "disabled")")
    }

    func getLatestReleaseInfo() -> String? {
        return appUpdater.downloadedAppBundle != nil ? "Update available" : nil
    }
}
