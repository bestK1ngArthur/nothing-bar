//
//  AppVersion.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Foundation
import Perception
import Sparkle
import SwiftUI

@Perceptible
final class AppVersion {

    private let updaterController: SPUStandardUpdaterController
    private let updaterDelegate: AppUpdateDelegate

    var isAutoUpdateEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "autoUpdateEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "autoUpdateEnabled")
            updateUpdaterPreferences()
        }
    }

    var isUpdateAvailable: Bool = false

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    init() {
        let updaterDelegate = AppUpdateDelegate()
        self.updaterDelegate = updaterDelegate
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: updaterDelegate,
            userDriverDelegate: updaterDelegate
        )
        updaterDelegate.appVersion = self

        if !UserDefaults.standard.bool(forKey: "autoUpdateEnabledSet") {
            UserDefaults.standard.set(true, forKey: "autoUpdateEnabled")
            UserDefaults.standard.set(true, forKey: "autoUpdateEnabledSet")
        }

        updateUpdaterPreferences()
        updaterController.startUpdater()
        updaterController.updater.checkForUpdatesInBackground()
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

private final class AppUpdateDelegate: NSObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {

    weak var appVersion: AppVersion?

    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        DispatchQueue.main.async { [weak self] in
            self?.appVersion?.isUpdateAvailable = true
        }
    }

    func updater(_ updater: SPUUpdater, didNotFindUpdate error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.appVersion?.isUpdateAvailable = false
        }
    }

    var supportsGentleScheduledUpdateReminders: Bool {
        true
    }

    func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        immediateFocus
    }

    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem,
        state: SPUUserUpdateState
    ) {
        guard !handleShowingUpdate else { return }

        DispatchQueue.main.async { [weak self] in
            self?.appVersion?.isUpdateAvailable = true
        }
    }
}
