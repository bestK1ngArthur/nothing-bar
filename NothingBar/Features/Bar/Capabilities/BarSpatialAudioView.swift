//
//  BarSpatialAudioView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftNothingEar
import SwiftUI

struct BarSpatialAudioView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        BarSectionView(
            title: "Spatial Audio",
            value: currentMode.displayName
        ) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(supportedModes.reversed(), id: \.self) { mode in
                    ModeCircleView<EmptyView>(
                        image: mode.imageName,
                        name: mode.displayName,
                        isActive: currentMode == mode
                    ) {
                        setMode(mode)
                    }
                }
            }
            .disabled(deviceState.spatialAudioMode == nil)
        }
    }

    private var currentMode: SpatialAudioMode {
        deviceState.spatialAudioMode ?? .off
    }

    private var supportedModes: [SpatialAudioMode] {
        guard let model = deviceState.model else {
            return []
        }

        return SpatialAudioMode.allSupported(by: model)
    }

    private var isCompatibleWithEnhancedBass: Bool {
        guard let model = deviceState.model else {
            return false
        }

        return SpatialAudioMode.isCompatibleWithEnhancedBass(by: model)
    }

    private func setMode(_ mode: SpatialAudioMode) {
        // Enhanced bass and spatial audio can't work simultaneously for some devices
        if !isCompatibleWithEnhancedBass,
            mode != .off,
            let bass = deviceState.enhancedBass,
            bass.isEnabled {
            let newBass = EnhancedBass(isEnabled: false, level: bass.level)
            nothing.setEnhancedBass(newBass)
            deviceState.enhancedBass = newBass
        }

        nothing.setSpatialAudioMode(mode)
        deviceState.spatialAudioMode = mode

        AppLogger.audio.uiSettingChanged("Spatial Audio", value: mode)
    }
}

private extension SpatialAudioMode {

    var imageName: ImageResource {
        switch self {
            case .headTracking:
                return .spatialAudioTracked
            case .fixed:
                return .spatialAudioFixed
            case .off:
                return .spatialAudioOff
        }
    }
}
