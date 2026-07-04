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
        static let deviceModelOverrides = "deviceModelOverrides"
    }

    var deviceState: DeviceState
    var appVersion: AppVersion
    var deviceSetupContext: DeviceSetupContext?

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
    @PerceptionIgnored
    var onOpenDeviceSetupRequested: (() -> Void)?

    var nothing: Device!

    private let batteryLowLevels = [20, 10, 5]
    private var deviceModelOverrides: [String: String]
    @PerceptionIgnored
    private var shouldOpenDeviceSetupWhenReady = false

    @MainActor
    init() {
        let defaults = UserDefaults.standard
        self.deviceState = DeviceState()
        self.appVersion = AppVersion()
        self.showConnectNotifications = defaults.object(forKey: Keys.showConnectNotifications) as? Bool ?? true
        self.showBatteryNotifications = defaults.object(forKey: Keys.showBatteryNotifications) as? Bool ?? true
        self.notificationStyle = NotificationStyle(
            rawValue: defaults.string(forKey: Keys.notificationStyle) ?? ""
        ) ?? .defaultValue
        self.hideMenuBarWhenDisconnected = defaults.object(forKey: Keys.hideMenuBarWhenDisconnected) as? Bool ?? false
        self.deviceModelOverrides = defaults.dictionary(forKey: Keys.deviceModelOverrides) as? [String: String] ?? [:]
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

        presentDeviceSetup(identity: identity, detectedModel: detectedModel)
    }

    @MainActor
    func applyDeviceModelSelection(_ selection: DeviceModelSelection) {
        guard let identity = deviceSetupContext?.identity ?? deviceState.deviceIdentity else {
            return
        }

        deviceModelOverrides[identity] = selection.id
        persistDeviceModelOverrides()
        applyEffectiveDeviceModel(selection.model)
        deviceSetupContext = nil
    }

    @MainActor
    func cancelDeviceSetup() {
        deviceSetupContext = nil
    }

    @MainActor
    func openPendingDeviceSetupIfNeeded() {
        guard shouldOpenDeviceSetupWhenReady else { return }

        shouldOpenDeviceSetupWhenReady = false
        onOpenDeviceSetupRequested?()
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
        let identity = deviceIdentity(
            bluetoothAddress: deviceInfo.bluetoothAddress,
            serialNumber: deviceInfo.serialNumber
        )

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

        if let overrideID = deviceModelOverrides[identity],
           let selection = DeviceModelSelection.selection(for: overrideID) {
            applyEffectiveDeviceModel(selection.model)
        } else {
            presentDeviceSetup(identity: identity, detectedModel: deviceInfo.model)
        }
    }

    @MainActor
    private func presentDeviceSetup(identity: String, detectedModel: DeviceModel) {
        deviceSetupContext = .init(identity: identity, detectedModel: detectedModel)

        guard let onOpenDeviceSetupRequested else {
            shouldOpenDeviceSetupWhenReady = true
            return
        }

        onOpenDeviceSetupRequested()
    }

    @MainActor
    private func applyEffectiveDeviceModel(_ model: DeviceModel) {
        deviceState.model = model
        nothing.overrideDeviceModel(model)
    }

    private func persistDeviceModelOverrides() {
        UserDefaults.standard.set(deviceModelOverrides, forKey: Keys.deviceModelOverrides)
    }

    private func deviceIdentity(bluetoothAddress: String?, serialNumber: String) -> String? {
        if let bluetoothAddress = normalizedIdentityValue(bluetoothAddress) {
            return bluetoothAddress
        }

        return normalizedIdentityValue(serialNumber)
    }

    private func normalizedIdentityValue(_ value: String?) -> String? {
        guard let value else { return nil }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "Unknown" else {
            return nil
        }

        return trimmed
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
                "Classic"
            case .apple:
                "Apple"
        }
    }

    var descriptionText: String {
        switch self {
            case .classic:
                "Larger, more detailed notification appearance."
            case .apple:
                "Compact style similar to native system accessories alerts."
        }
    }

    var placementText: String {
        switch self {
            case .classic:
                "Top-right corner of the screen"
            case .apple:
                "Under the menu bar item"
        }
    }
}
