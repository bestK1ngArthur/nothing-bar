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
                ForEach(NoiseCancellationMode.allCases, id: \.self) { mode in
                    noiseCancellationItem(mode)
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
            isActive: isActive
        ) {
            nothing.setNoiseCancellationMode(mode)
            AppLogger.audio.uiSettingChanged("Noise Cancellation", value: mode)
        } overlay: {
            if case .active(let activeMode) = currentMode, isActive {
                AnyView(noiseCancellationMenu(currentMode: activeMode))
            } else {
                AnyView(EmptyView())
            }
        }
    }

    private func noiseCancellationMenu(currentMode: NoiseCancellationMode.Active) -> some View {
        Menu {
            ForEach(NoiseCancellationMode.Active.allCases, id: \.self) { mode in
                Button {
                    nothing.setNoiseCancellationMode(.active(mode))
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
