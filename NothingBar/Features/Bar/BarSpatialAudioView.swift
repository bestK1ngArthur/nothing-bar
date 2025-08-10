//
//  BarSpatialAudioView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar

struct BarSpatialAudioView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: NothingEar.Device {
        appData.nothing
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Spatial audio")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: 8) {
                ForEach(SpatialAudioMode.allCases, id: \.self) { mode in
                    Button(action: {
                        deviceState.spatialAudioMode = mode
                        AppLogger.ui.uiSettingChanged("Spatial Audio Mode", value: mode.rawValue)
                        // TODO: Implement when api will be ready
                    }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(deviceState.spatialAudioMode == mode ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                                    .frame(width: 44, height: 44)

                                Image(systemName: mode.systemImage)
                                    .font(.system(size: 20))
                                    .foregroundColor(deviceState.spatialAudioMode == mode ? .white : .primary)
                            }
                            .frame(width: 60, height: 60)

                            Text(mode.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 66)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
