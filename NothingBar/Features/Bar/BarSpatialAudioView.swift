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
                        // Интеграция с NothingEar API для Spatial Audio
                        // Метод setSpatialAudioMode не доступен в текущей версии библиотеки
                        print("Spatial Audio Mode changed to: \(mode.rawValue)")
                        // TODO: Реализовать когда API будет доступно
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
                    .onHover { _ in
                        // Добавляем hover эффект
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
