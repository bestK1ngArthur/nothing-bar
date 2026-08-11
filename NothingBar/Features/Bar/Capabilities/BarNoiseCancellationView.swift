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
            let currentMode = deviceState.noiseCancellationMode ?? .off
            let isDisabled = deviceState.noiseCancellationMode == nil

            BarSectionView(
                title: "Noise Cancellation",
                value: displayValue(for: currentMode)
            ) {
                VStack(alignment: .center, spacing: 12) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(NoiseCancellationMode.allCases, id: \.self) { mode in
                            noiseCancellationItem(mode, currentMode: currentMode)
                        }
                    }

                    if case .active(let currentLevel) = currentMode {
                        activeLevelsStack(currentLevel: currentLevel)
                    }
                }
                .disabled(isDisabled)
            }
        }
    }

    @ViewBuilder
    private func noiseCancellationItem(
        _ mode: NoiseCancellationMode,
        currentMode: NoiseCancellationMode
    ) -> some View {
        let isActive = modeIsEquivalent(mode, currentMode)
        ModeCircleView(
            image: mode.imageName,
            name: mode.localizedDisplayName,
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

                Text(level.localizedDisplayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func displayValue(for mode: NoiseCancellationMode) -> String {
        switch mode {
            case .active(let mode):
                return mode.localizedDisplayName
            default:
                return mode.localizedDisplayName
        }
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

    /// SwiftNothingEar's own `.displayName` is not localized — this is our own
    /// translated label for the mode circle and section value.
    var localizedDisplayName: String {
        switch self {
            case .off:
                String(localized: "Off", comment: "Noise cancellation mode")
            case .transparent:
                String(localized: "Transparency", comment: "Noise cancellation mode")
            case .active:
                String(localized: "Active", comment: "Noise cancellation mode")
        }
    }
}

private extension NoiseCancellationMode.Active {

    var localizedDisplayName: String {
        switch self {
            case .low:
                String(localized: "Low", comment: "Noise cancellation active level")
            case .mid:
                String(localized: "Mid", comment: "Noise cancellation active level")
            case .high:
                String(localized: "High", comment: "Noise cancellation active level")
            case .adaptive:
                String(localized: "Adaptive", comment: "Noise cancellation active level")
        }
    }
}
