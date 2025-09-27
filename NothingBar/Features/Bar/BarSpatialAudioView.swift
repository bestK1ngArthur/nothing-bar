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
                    Button {
                        nothing.setSpatialAudioMode(mode)
                        deviceState.spatialAudioMode = mode
                    } label: {
                        VStack(spacing: 0) {
                            let isActive = currentMode == mode
                            ZStack {
                                Circle()
                                    .fill(isActive ? Color.accentColor : Color.gray)
                                    .frame(width: 44, height: 44)

                                Image(mode.imageName)
                                    .renderingMode(.template)
                                    .foregroundColor(isActive ? .white : .primary)
                            }
                            .frame(width: 60, height: 60)

                            Text(mode.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: 66)
                    }
                    .buttonStyle(PlainButtonStyle())
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
