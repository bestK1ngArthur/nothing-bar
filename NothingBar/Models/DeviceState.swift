//
//  DeviceState.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
import SwiftNothingEar
import SwiftUI

@Perceptible
class DeviceState {

    var isConnected: Bool = false
    var bluetoothError: ConnectionError.Bluetooth?

    var detectedModel: DeviceModel?
    var model: DeviceModel?
    var deviceIdentity: String?
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
    var gestures: [DeviceGesture] = []

    var lowLatency: Bool = false
    var inEarDetection: Bool = false
}
