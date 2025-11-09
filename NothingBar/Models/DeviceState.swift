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

    var model: NothingEar.Model?
    var firmwareVersion: String?
    var serialNumber: String?
    var bluetoothAddress: String?

    var battery: NothingEar.Battery?
    var ancMode: NothingEar.ANCMode?
    var spatialAudioMode: NothingEar.SpatialAudioMode?
    var eqPreset: NothingEar.EQPreset?
    var enhancedBass: NothingEar.EnhancedBassSettings?
    var ringBuds: NothingEar.RingBuds?

    var lowLatency: Bool = false
    var inEarDetection: Bool = false
}
