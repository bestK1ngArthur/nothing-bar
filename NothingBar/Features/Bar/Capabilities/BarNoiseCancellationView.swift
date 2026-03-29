//
//  BarNoiseCancellationView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

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
        BarSectionView(
            title: "Noise Cancellation",
            value: value
        ) {
            VStack(alignment: .center, spacing: 12) {
                // Main ANC modes as circles
                HStack(alignment: .top, spacing: 8) {
                    ForEach(NoiseCancellationMode.allCases, id: \.self) { mode in
                        noiseCancellationItem(mode)
                    }
                }
                
                // Sub-levels for active mode with labels
                if case .active(let activeMode) = currentMode {
                    VStack(alignment: .center, spacing: 6) {
                        HStack(spacing: 12) {
                            ForEach(NoiseCancellationMode.Active.allCases, id: \.self) { level in
                                VStack(spacing: 4) {
                                    levelPill(level, isSelected: activeMode == level)
                                    Text(level.displayName)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .disabled(deviceState.noiseCancellationMode == nil)
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
    
    @ViewBuilder
    private func levelPill(_ level: NoiseCancellationMode.Active, isSelected: Bool) -> some View {
        Button {
            nothing.setNoiseCancellationMode(.active(level))
        } label: {
            RoundedRectangle(cornerRadius: 3)
                .fill(isSelected ? Color.accentColor : Color.white.opacity(0.3))
                .frame(height: 6)
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
