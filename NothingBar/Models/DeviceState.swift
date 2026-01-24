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

    var model: DeviceModel?
    var firmwareVersion: String?
    var serialNumber: String?
    var bluetoothAddress: String?

    var battery: Battery?
    var noiseCancellationMode: NoiseCancellationMode?
    var spatialAudioMode: SpatialAudioMode?
    var eqPreset: EQPreset?
    var eqPresetCustom: EQPresetCustom?
    var enhancedBass: EnhancedBass?
    var ringBuds: RingBuds?

    var lowLatency: Bool = false
    var inEarDetection: Bool = false
}
