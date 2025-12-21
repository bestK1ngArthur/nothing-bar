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
            HStack(alignment: .top, spacing: 8) {
                ForEach(ANCMode.allCases, id: \.self) { mode in
                    let isActive = modeIsEquivalent(mode, currentMode)
                    ModeCircleView(
                        image: mode.imageName,
                        name: mode.displayName,
                        isActive: isActive
                    ) {
                        nothing.setANCMode(mode)
                        AppLogger.audio.uiSettingChanged("Noise Cancellation", value: mode)
                    } overlay: {
                        if case .noiseCancellation(let noiseMode) = currentMode, isActive {
                            AnyView(noiseCancellationMenu(currentMode: noiseMode))
                        } else {
                            AnyView(EmptyView())
                        }
                    }
                }
            }
            .disabled(deviceState.ancMode == nil)
        }
    }

    private func noiseCancellationMenu(currentMode: ANCMode.NoiseCancellation) -> some View {
        Menu {
            ForEach(ANCMode.NoiseCancellation.allCases, id: \.self) { mode in
                Button {
                    nothing.setANCMode(.noiseCancellation(mode))
                } label: {
                    Text(mode.displayName) + (currentMode == mode ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
            }
        }
    }

    private var value: String {
        switch currentMode {
            case .noiseCancellation(let mode):
                return mode.displayName
            default:
                return currentMode.displayName
        }
    }

    private var currentMode: ANCMode {
        deviceState.ancMode ?? .off
    }

    private func modeIsEquivalent(_ mode1: ANCMode, _ mode2: ANCMode) -> Bool {
        switch (mode1, mode2) {
            case (.noiseCancellation, .noiseCancellation),
                 (.transparent, .transparent),
                 (.off, .off):
                return true
            default:
                return false
        }
    }
}

private extension ANCMode {

    var imageName: ImageResource {
        switch self {
            case .noiseCancellation:
                return .ancActive
            case .transparent:
                return .ancTransparent
            case .off:
                return .ancOff
        }
    }
}
