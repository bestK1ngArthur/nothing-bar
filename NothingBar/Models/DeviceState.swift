//
//  DeviceState.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftNothingEar
import SwiftUI

@Observable
class DeviceState {

    var isConnected: Bool = false
    var bluetoothError: NothingEar.ConnectionError.Bluetooth?
    var model: NothingEar.Model = .ear(.black)
    var firmwareVersion: String = "Unknown"
    var serialNumber: String = "Unknown"
    var bluetoothAddress: String = "Unknown"

    var battery: NothingEar.Battery?
    var ancMode: NothingEar.ANCMode?
    var spatialAudioMode: NothingEar.SpatialAudioMode?
    var eqPreset: NothingEar.EQPreset?
    var enhancedBass: NothingEar.EnhancedBassSettings?

    var lowLatency: Bool = false
    var inEarDetection: Bool = false
}
