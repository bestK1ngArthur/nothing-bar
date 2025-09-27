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
    var nothing: NothingEar.Device!

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
                    AppLogger.connection.connectionChanged(true, result: "\(result)")
                },
                onDisconnect: { [weak self] result in
                    self?.deviceState.isConnected = false
                    AppLogger.connection.connectionChanged(false, result: "\(result)")
                },
                onUpdateBattery: { [weak self] battery in
                    self?.deviceState.battery = battery
                },
                onUpdateANCMode: { [weak self] ancMode in
                    if let ancMode {
                        self?.deviceState.ancMode = ancMode
                    }
                    AppLogger.device.deviceSettingChanged("ANCMode", value: ancMode?.displayName ?? "nil")
                },
                onUpdateSpatialAudio: { [weak self] spatialAudioMode in
                    if let spatialAudioMode {
                        self?.deviceState.spatialAudioMode = spatialAudioMode
                    }
                    AppLogger.device.deviceSettingChanged("SpatialAudio", value: spatialAudioMode?.displayName ?? "nil")
                },
                onUpdateEnhancedBass: { [weak self] enhancedBass in
                    self?.deviceState.enhancedBass = enhancedBass
                    AppLogger.device.deviceSettingChanged("EnhancedBass", value: "\(enhancedBass?.isEnabled ?? false)")
                },
                onUpdateEQPreset: { [weak self] eqPreset in
                    if let eqPreset {
                        self?.deviceState.eqPreset = eqPreset
                    }
                    AppLogger.device.deviceSettingChanged("EQPreset", value: eqPreset?.displayName ?? "nil")
                },
                onUpdateDeviceSettings: { [weak self] settings in
                    self?.deviceState.inEarDetection = settings.inEarDetection
                    self?.deviceState.lowLatency = settings.lowLatency
                    AppLogger.device.deviceSettingChanged("DeviceSettings", value: "\(String(describing: settings))")
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
}
