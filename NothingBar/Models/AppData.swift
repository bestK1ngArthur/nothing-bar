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
    var nothing: NothingEar.Device!

    @MainActor
    init() {
        self.deviceState = DeviceState()
        self.nothing = NothingEar.Device(
            .init(
                onDiscover: { device in
                    print("Discovered device: \(device)")
                },
                onConnect: { [weak self] result in
                    self?.deviceState.isConnected = true

                    if case let .success(deviceInfo) = result {
                        self?.deviceState.model = deviceInfo.model
                        self?.deviceState.serialNumber = deviceInfo.serialNumber
                        self?.deviceState.bluetoothAddress = deviceInfo.bluetoothAddress ?? "Unknown"
                        self?.deviceState.firmwareVersion = deviceInfo.firmwareVersion ?? "Unknown"
                    }
                    print("Connected: \(result)")
                },
                onDisconnect: { [weak self] result in
                    self?.deviceState.isConnected = false
                    print("Disconnected: \(result)")
                },
                onUpdateBattery: { [weak self] battery in
                    self?.deviceState.battery = battery
                },
                onUpdateANCMode: { [weak self] ancMode in
                    if let ancMode {
                        self?.deviceState.ancMode = ancMode

                    }
                    print("ANCMode: \(ancMode?.displayName))")
                },
                onUpdateEnhancedBass: { [weak self] enhancedBass in
                    self?.deviceState.enhancedBass = enhancedBass
                    print("EnhancedBass: \(enhancedBass?.isEnabled))")
                },
                onUpdateEQPreset: { [weak self] eqPreset in
                    if let eqPreset {
                        self?.deviceState.eqPreset = eqPreset
                    }
                    print("EQPreset: \(eqPreset?.displayName)")
                },
                onUpdateDeviceSettings: { [weak self] settings in
                    self?.deviceState.inEarDetection = settings.inEarDetection
                    self?.deviceState.lowLatency = settings.lowLatency
                    print("DeviceSettings: \(String(describing: settings))")
                },
                onError: { error in
                    print("Error: \(error)")
                }
            )
        )
    }
}
