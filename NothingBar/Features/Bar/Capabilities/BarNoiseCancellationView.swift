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
    @State private var currentMode: NoiseCancellationMode = .off
    @State private var pendingUserMode: NoiseCancellationMode?

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        WithPerceptionTracking {
            let reportedMode = deviceState.noiseCancellationMode
            let isDisabled = reportedMode == nil

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
            .onAppear {
                syncFromDevice(reportedMode)
            }
            .onChange(of: reportedMode) { newMode in
                syncFromDevice(newMode)
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
            name: mode.displayName,
            isActive: isActive,
            onTap: {
                setMode(mode)
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
            setMode(.active(level))
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

    private func setMode(_ mode: NoiseCancellationMode) {
        pendingUserMode = mode
        currentMode = mode
        nothing.setNoiseCancellationMode(mode)
        deviceState.noiseCancellationMode = mode
        AppLogger.audio.uiSettingChanged("Noise Cancellation", value: mode)
    }

    private func syncFromDevice(_ reportedMode: NoiseCancellationMode?) {
        guard let reportedMode else {
            return
        }

        if let pendingUserMode {
            if modeIsEquivalent(pendingUserMode, reportedMode) {
                self.pendingUserMode = nil
                currentMode = reportedMode
            }
            return
        }

        currentMode = reportedMode
    }

    private func displayValue(for mode: NoiseCancellationMode) -> String {
        switch mode {
            case .active(let mode):
                return mode.displayName
            default:
                return mode.displayName
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
}