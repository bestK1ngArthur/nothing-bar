//
//  AppData.swift
//  NothingBar
//
//  Created by Artem Belkov on 05.08.2025.
//

import Foundation
import Perception
import SwiftNothingEar

@Perceptible
class AppData {

    private enum Keys {
        static let showConnectNotifications = "showNotifications"
        static let showBatteryNotifications = "showBatteryNotifications"
        static let notificationStyle = "notificationStyle"
        static let hideMenuBarWhenDisconnected = "hideMenuBarWhenDisconnected"
    }

    @PerceptionIgnored
    var deviceState: DeviceState
    @PerceptionIgnored
    var appVersion: AppVersion
    @PerceptionIgnored
    var deviceSetupState: DeviceSetupState

    var showConnectNotifications: Bool = true
    var showBatteryNotifications: Bool = true
    var notificationStyle: NotificationStyle = .defaultValue
    var hideMenuBarWhenDisconnected: Bool = false {
        didSet {
            UserDefaults.standard.set(hideMenuBarWhenDisconnected, forKey: Keys.hideMenuBarWhenDisconnected)
            onHideMenuPreferenceChanged?(hideMenuBarWhenDisconnected)
        }
    }

    @PerceptionIgnored
    var onConnectionStateChanged: ((Bool) -> Void)?
    @PerceptionIgnored
    var onHideMenuPreferenceChanged: ((Bool) -> Void)?
    @PerceptionIgnored
    var onOpenSettingsRequested: (() -> Void)?

    var nothing: Device!

    private let batteryLowLevels = [20, 10, 5]
    private let deviceModelSelectionStore: DeviceModelSelectionStore

    @MainActor
    init() {
        let defaults = UserDefaults.standard
        self.deviceState = DeviceState()
        self.appVersion = AppVersion()
        self.deviceSetupState = DeviceSetupState()
        self.deviceModelSelectionStore = DeviceModelSelectionStore(defaults: defaults)
        self.showConnectNotifications = defaults.object(forKey: Keys.showConnectNotifications) as? Bool ?? true
        self.showBatteryNotifications = defaults.object(forKey: Keys.showBatteryNotifications) as? Bool ?? true
        self.notificationStyle = NotificationStyle(
            rawValue: defaults.string(forKey: Keys.notificationStyle) ?? ""
        ) ?? .defaultValue
        self.hideMenuBarWhenDisconnected = defaults.object(forKey: Keys.hideMenuBarWhenDisconnected) as? Bool ?? false
        self.nothing = Device(
            .init(
                onDiscover: { device in
                    AppLogger.device.deviceDiscovered("\(device)")
                },
                onConnect: { [weak self] result in
                    self?.deviceState.isConnected = true
                    Task { @MainActor in
                        self?.onConnectionStateChanged?(true)
                    }

                    if case let .success(deviceInfo) = result {
                        Task { @MainActor in
                            self?.handleSuccessfulConnection(deviceInfo)
                            self?.showNotification()
                        }
                    } else {
                        self?.showNotification()
                    }

                    AppLogger.connection.connectionChanged(true, result: "\(result)")
                },
                onDisconnect: { [weak self] result in
                    self?.deviceState.isConnected = false
                    Task { @MainActor in
                        self?.onConnectionStateChanged?(false)
                    }
                    self?.showNotification()

                    AppLogger.connection.connectionChanged(false, result: "\(result)")
                },
                onUpdateBattery: { [weak self] battery in
                    self?.showBatteryLevelNotification(battery)
                    self?.deviceState.battery = battery

                    AppLogger.device.deviceStateChanged("Battery", value: battery)
                },
                onUpdateANCMode: { [weak self] newMode in
                    if let newMode {
                        self?.deviceState.noiseCancellationMode = newMode
                    }
                    AppLogger.device.deviceStateChanged("Noise Cancellation", value: newMode)
                },
                onUpdateSpatialAudio: { [weak self] newMode in
                    if let newMode {
                        self?.deviceState.spatialAudioMode = newMode
                    }
                    AppLogger.device.deviceStateChanged("Spatial Audio", value: newMode)
                },
                onUpdateEnhancedBass: { [weak self] enhancedBass in
                    self?.deviceState.enhancedBass = enhancedBass
                    AppLogger.device.deviceStateChanged("Enhanced Bass", value: enhancedBass?.isEnabled)
                },
                onUpdateEQPreset: { [weak self] eqPreset in
                    if let eqPreset {
                        self?.deviceState.eqPreset = eqPreset
                    }
                    AppLogger.device.deviceStateChanged("EQ Preset", value: eqPreset?.displayName)
                },
                onUpdateEQPresetCustom: { [weak self] eqPresetCustom in
                    self?.deviceState.eqPresetCustom = eqPresetCustom
                    AppLogger.device.deviceStateChanged("EQ Preset Custom", value: eqPresetCustom)
                },
                onUpdateDeviceSettings: { [weak self] settings in
                    self?.deviceState.inEarDetection = settings.inEarDetection
                    self?.deviceState.lowLatency = settings.lowLatency
                    AppLogger.device.deviceStateChanged("Device Settings", value: settings)
                },
                onUpdateRingBuds: { [weak self] ringBuds in
                    self?.deviceState.ringBuds = ringBuds
                    AppLogger.device.deviceStateChanged("Ring Buds", value: ringBuds)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                    AppLogger.main.logError("\(error)")
                }
            )
        )
    }

    @MainActor
    func requestCurrentDeviceSetup() {
        guard let identity = deviceState.deviceIdentity,
              let detectedModel = deviceState.detectedModel ?? deviceState.model else {
            return
        }

        presentDeviceSetup(identity: identity, detectedModel: detectedModel, mode: .editSelection)
    }

    @MainActor
    func applyDeviceModelSelection(_ selection: DeviceModelSelection) {
        guard let identity = deviceSetupState.context?.identity ?? deviceState.deviceIdentity else {
            return
        }

        deviceModelSelectionStore.save(
            selection: selection,
            identity: identity,
            detectedModel: deviceSetupState.context?.detectedModel ?? deviceState.detectedModel
        )
        applyEffectiveDeviceModel(selection.model)
        deviceSetupState.cancel()
    }

    @MainActor
    func cancelDeviceSetup() {
        deviceSetupState.cancel()
    }

    @MainActor
    func openPendingDeviceSetupIfNeeded() {
        deviceSetupState.openPendingIfNeeded()
    }

    private func handleError(_ error: Error) {
        guard let connectionError = error as? ConnectionError else {
            return
        }

        switch connectionError {
            case .bluetooth(let bluetoothError):
                deviceState.bluetoothError = bluetoothError
                AppLogger.connection.connectionError("Bluetooth error: \(bluetoothError)")
            default:
                deviceState.bluetoothError = nil
                AppLogger.connection.connectionError("Other connection error: \(connectionError)")
        }
    }

    @MainActor
    private func handleSuccessfulConnection(_ deviceInfo: DeviceInfo) {
        let identity = deviceModelSelectionStore.identity(for: deviceInfo)

        deviceState.bluetoothError = nil
        deviceState.detectedModel = deviceInfo.model
        deviceState.model = deviceInfo.model
        deviceState.deviceIdentity = identity
        deviceState.serialNumber = deviceInfo.serialNumber
        deviceState.bluetoothAddress = deviceInfo.bluetoothAddress ?? "Unknown"
        deviceState.firmwareVersion = deviceInfo.firmwareVersion ?? "Unknown"

        guard let identity else {
            return
        }

        if let selection = deviceModelSelectionStore.selection(for: identity) {
            applyEffectiveDeviceModel(selection.model)
        } else {
            presentDeviceSetup(identity: identity, detectedModel: deviceInfo.model, mode: .newDevice)
        }
    }

    @MainActor
    private func presentDeviceSetup(identity: String, detectedModel: DeviceModel, mode: DeviceSetupMode) {
        deviceSetupState.present(identity: identity, detectedModel: detectedModel, mode: mode)
    }

    @MainActor
    private func applyEffectiveDeviceModel(_ model: DeviceModel) {
        deviceState.model = model
        nothing.setEffectiveModelOverride(model)
    }

    @MainActor
    private func showBatteryLevelNotification(_ battery: Battery?) {
        guard showBatteryNotifications, let battery else { return }

        let needNotification = if let oldLevel = deviceState.battery?.level {
            batteryLowLevels.contains { lowLevel in
                oldLevel > lowLevel && battery.level <= lowLevel
            }
        } else {
            batteryLowLevels.contains(battery.level)
        }

        if needNotification {
            BarNotificationCenter.shared.show(with: self)
        }
    }

    @MainActor
    private func showNotification() {
        guard showConnectNotifications else { return }

        BarNotificationCenter.shared.show(with: self)
    }
}

private extension Battery {

    var level: Int {
        switch self {
            case .budsWithCase(_, let leftBud, let rightBud):
                leftBud.level < rightBud.level ? leftBud.level : rightBud.level

            case .single(let battery):
                battery.level
        }
    }
}

enum NotificationStyle: String, CaseIterable, Identifiable {
    case classic
    case apple

    var id: String { rawValue }
    static let defaultValue: NotificationStyle = .apple

    var displayName: String {
        switch self {
            case .classic:
                String(localized: "Classic", comment: "Notification style option name")
            case .apple:
                String(localized: "Apple", comment: "Notification style option name")
        }
    }

    var descriptionText: String {
        switch self {
            case .classic:
                String(localized: "Larger, more detailed notification appearance.", comment: "Notification style description")
            case .apple:
                String(localized: "Compact style similar to native system accessories alerts.", comment: "Notification style description")
        }
    }

    var placementText: String {
        switch self {
            case .classic:
                String(localized: "Top-right corner of the screen", comment: "Notification style placement on screen")
            case .apple:
                String(localized: "Under the menu bar item", comment: "Notification style placement on screen")
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case spanish = "es-ES"
    case catalan = "ca-ES"

    var id: String { rawValue }
    static let defaultValue: AppLanguage = .system

    /// Language names are shown as endonyms (each language's own name for itself), matching
    /// the convention used by iOS/macOS system language pickers — so this deliberately does
    /// not use String(localized:) except for "System", which isn't a language name.
    var displayName: String {
        switch self {
            case .system:
                String(localized: "System", comment: "Language picker option: follow the macOS system language")
            case .english:
                "English"
            case .spanish:
                "Español"
            case .catalan:
                "Català"
        }
    }
}
