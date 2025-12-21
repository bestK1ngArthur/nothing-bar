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
    var bluetoothError: ConnectionError.Bluetooth?

    var model: Model?
    var firmwareVersion: String?
    var serialNumber: String?
    var bluetoothAddress: String?

    var battery: Battery?
    var ancMode: ANCMode?
    var spatialAudioMode: SpatialAudioMode?
    var eqPreset: EQPreset?
    var enhancedBass: EnhancedBassSettings?
    var ringBuds: RingBuds?

    var lowLatency: Bool = false
    var inEarDetection: Bool = false
}
