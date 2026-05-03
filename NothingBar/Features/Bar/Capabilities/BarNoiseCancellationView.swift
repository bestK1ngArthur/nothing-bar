//
//  BarNoiseCancellationView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
import SwiftNothingEar
import SwiftUI

struct BarNoiseCancellationView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        WithPerceptionTracking {
            BarSectionView(
                title: "Noise Cancellation",
                value: value
            ) {
                VStack(alignment: .center, spacing: 12) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(NoiseCancellationMode.allCases, id: \.self) { mode in
                            noiseCancellationItem(mode)
                        }
                    }

                    if case .active(let currentLevel) = currentMode {
                        activeLevelsStack(currentLevel: currentLevel)
                    }
                }
                .disabled(deviceState.noiseCancellationMode == nil)
            }
        }
    }

    @ViewBuilder
    private func noiseCancellationItem(_ mode: NoiseCancellationMode) -> some View {
        let isActive = modeIsEquivalent(mode, currentMode)
        ModeCircleView(
            image: mode.imageName,
            name: mode.displayName,
            isActive: isActive,
            onTap: {
                nothing.setNoiseCancellationMode(mode)
                AppLogger.audio.uiSettingChanged("Noise Cancellation", value: mode)
            },
            overlay: { EmptyView() }
        )
    }

    private func activeLevelsStack(currentLevel: NoiseCancellationMode.Active) -> some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 12) {
                ForEach(NoiseCancellationMode.Active.allCases, id: \.self) { level in
                    activeLevelView(level, isSelected: currentLevel == level)
                }
            }
        }
    }

    @ViewBuilder
    private func activeLevelView(_ level: NoiseCancellationMode.Active, isSelected: Bool) -> some View {
        Button {
            nothing.setNoiseCancellationMode(.active(level))
        } label: {
            VStack(spacing: 4) {

            RoundedRectangle(cornerRadius: 3)
                .fill(isSelected ? Color.accentColor : Color.secondary)
                .frame(height: 6)

                Text(level.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var value: String {
        switch currentMode {
            case .active(let mode):
                return mode.displayName
            default:
                return currentMode.displayName
        }
    }

    private var currentMode: NoiseCancellationMode {
        deviceState.noiseCancellationMode ?? .off
    }

    private func modeIsEquivalent(_ mode1: NoiseCancellationMode, _ mode2: NoiseCancellationMode) -> Bool {
        switch (mode1, mode2) {
            case (.active, .active),
                 (.transparent, .transparent),
                 (.off, .off):
                return true
            default:
                return false
        }
    }
}

private extension NoiseCancellationMode {

    var imageName: ImageResource {
        switch self {
            case .active:
                return .ancActive
            case .transparent:
                return .ancTransparent
            case .off:
                return .ancOff
        }
    }
}
