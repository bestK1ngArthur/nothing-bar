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

    private var nothing: NothingEar.Device {
        appData.nothing
    }

    var body: some View {
        BarSectionView(
            title: "Noise cancellation",
            value: value
        ) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(NothingEar.ANCMode.allCases, id: \.self) { mode in
                    Button {
                        nothing.setANCMode(mode)
                    } label: {
                        VStack(spacing: 0) {
                            let isActive = modeIsEquivalent(mode, currentMode)
                            ZStack {
                                Circle()
                                    .fill(isActive ? Color.accentColor : Color.gray)
                                    .frame(width: 44, height: 44)

                                Image(mode.imageName)
                                    .font(.system(size: 20))
                                    .foregroundColor(isActive ? .white : .primary)
                            }
                            .frame(width: 60, height: 60)
                            .overlay(alignment: .topTrailing) {
                                if case .noiseCancellation(let noiseMode) = currentMode, isActive {
                                    noiseCancellationMenu(currentMode: noiseMode)
                                }
                            }

                            Text(mode.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 66)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .disabled(deviceState.ancMode == nil)
        }
    }

    private func noiseCancellationMenu(currentMode: NothingEar.ANCMode.NoiseCancellation) -> some View {
        Menu {
            ForEach(NothingEar.ANCMode.NoiseCancellation.allCases, id: \.self) { mode in
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

    private var currentMode: NothingEar.ANCMode {
        deviceState.ancMode ?? .off
    }

    private func modeIsEquivalent(_ mode1: NothingEar.ANCMode, _ mode2: NothingEar.ANCMode) -> Bool {
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

private extension NothingEar.ANCMode {

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
