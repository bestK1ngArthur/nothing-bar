//
//  AppData.swift
//  NothingBar
//
//  Created by Artem Belkov on 05.08.2025.
//

import Foundation
import SwiftNothingEar

@Observable
class AppData {

    var deviceState: DeviceState
    var appVersion: AppVersion

    var showNotifications: Bool = true

    var nothing: NothingEar.Device!

    private let batteryLowLevel = 20 // 20%

    @MainActor
    init() {
        self.deviceState = DeviceState()
        self.appVersion = AppVersion()
        self.nothing = NothingEar.Device(
            .init(
                onDiscover: { device in
                    AppLogger.device.deviceDiscovered("\(device)")
                },
                onConnect: { [weak self] result in
                    self?.deviceState.isConnected = true

                    if case let .success(deviceInfo) = result {
                        self?.deviceState.bluetoothError = nil
                        self?.deviceState.model = deviceInfo.model
                        self?.deviceState.serialNumber = deviceInfo.serialNumber
                        self?.deviceState.bluetoothAddress = deviceInfo.bluetoothAddress ?? "Unknown"
                        self?.deviceState.firmwareVersion = deviceInfo.firmwareVersion ?? "Unknown"
                    }

                    self?.showNotification()

                    AppLogger.connection.connectionChanged(true, result: "\(result)")
                },
                onDisconnect: { [weak self] result in
                    self?.deviceState.isConnected = false
                    self?.showNotification()

                    AppLogger.connection.connectionChanged(false, result: "\(result)")
                },
                onUpdateBattery: { [weak self] battery in
                    self?.showBatteryLevelNotification(battery)
                    self?.deviceState.battery = battery

                    AppLogger.device.deviceSettingChanged("Battery", value: battery)
                },
                onUpdateANCMode: { [weak self] newMode in
                    if let newMode {
                        self?.deviceState.ancMode = newMode
                    }
                    AppLogger.device.deviceSettingChanged("Noise Cancellation", value: newMode)
                },
                onUpdateSpatialAudio: { [weak self] newMode in
                    if let newMode {
                        self?.deviceState.spatialAudioMode = newMode
                    }
                    AppLogger.device.deviceSettingChanged("Spatial Audio", value: newMode)
                },
                onUpdateEnhancedBass: { [weak self] enhancedBass in
                    self?.deviceState.enhancedBass = enhancedBass
                    AppLogger.device.deviceSettingChanged("Enhanced Bass", value: enhancedBass?.isEnabled)
                },
                onUpdateEQPreset: { [weak self] eqPreset in
                    if let eqPreset {
                        self?.deviceState.eqPreset = eqPreset
                    }
                    AppLogger.device.deviceSettingChanged("EQ Preset", value: eqPreset?.displayName)
                },
                onUpdateDeviceSettings: { [weak self] settings in
                    self?.deviceState.inEarDetection = settings.inEarDetection
                    self?.deviceState.lowLatency = settings.lowLatency
                    AppLogger.device.deviceSettingChanged("Device Settings", value: settings)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                    AppLogger.main.logError("\(error)")
                }
            )
        )
    }

    private func handleError(_ error: Error) {
        guard let connectionError = error as? NothingEar.ConnectionError else {
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
    private func showBatteryLevelNotification(_ battery: NothingEar.Battery?) {
        guard let battery else { return }

        let needNotification = if let oldLevel = deviceState.battery?.level {
            oldLevel > batteryLowLevel && battery.level <= batteryLowLevel
        } else {
            battery.level == batteryLowLevel
        }

        if needNotification {
            showNotification()
        }
    }

    @MainActor
    private func showNotification() {
        guard showNotifications else { return }

        BarNotificationCenter.shared.show(with: self)
    }
}

private extension NothingEar.Battery {

    var level: Int {
        switch self {
            case .budsWithCase(_, let leftBud, let rightBud):
                leftBud.level < rightBud.level ? leftBud.level : rightBud.level

            case .single(let battery):
                battery.level
        }
    }
}
