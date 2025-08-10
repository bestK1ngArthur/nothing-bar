//
//  DeviceState.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar

// MARK: - Device State

@Observable
class DeviceState {

    var isConnected: Bool = false
    var hasBluetoothPermissions: Bool = true
    var model: NothingEar.Model = .ear
    var firmwareVersion: String = "Unknown"
    var serialNumber: String = "Unknown"
    var bluetoothAddress: String = "Unknown"

    var battery: NothingEar.Battery?
    var ancMode: NothingEar.ANCMode?
    var spatialAudioMode: SpatialAudioMode = .fixed
    var eqPreset: NothingEar.EQPreset?
    var enhancedBass: NothingEar.EnhancedBassSettings?

    var lowLatency: Bool = false
    var inEarDetection: Bool = false
}

enum SpatialAudioMode: String, CaseIterable {

    case headTracking = "Head-tracking"
    case fixed = "Fixed"
    case off = "Off"

    var systemImage: String {
        switch self {
            case .headTracking: return "location.circle"
            case .fixed: return "location.circle.fill"
            case .off: return "speaker.slash.circle"
        }
    }
}
