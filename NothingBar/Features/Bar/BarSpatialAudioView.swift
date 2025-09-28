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

    private var nothing: NothingEar.Device {
        appData.nothing
    }

    var body: some View {
        BarSectionView(
            title: "Spatial Audio",
            value: currentMode.displayName
        ) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(NothingEar.SpatialAudioMode.allCases.reversed(), id: \.self) { mode in
                    ModeCircleView<EmptyView>(
                        image: mode.imageName,
                        name: mode.displayName,
                        isActive: currentMode == mode
                    ) {
                        nothing.setSpatialAudioMode(mode)
                        deviceState.spatialAudioMode = mode
                    }
                }
            }
            .disabled(deviceState.spatialAudioMode == nil)
        }
    }

    private var currentMode: NothingEar.SpatialAudioMode {
        deviceState.spatialAudioMode ?? .off
    }
}

private extension NothingEar.SpatialAudioMode {

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
