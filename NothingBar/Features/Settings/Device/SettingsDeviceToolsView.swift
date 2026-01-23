//
//  SettingsDeviceToolsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftNothingEar
import SwiftUI

struct SettingsDeviceToolsView: View {

    @Environment(AppData.self) private var appData

    @State private var showRingBudsAlert = false
    @State private var pendingRingBuds: RingBuds?

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        @Bindable var bindableAppData = appData
        Group {
            SettingsRow(
                title: "Low lag mode",
                description: "Minimise latency for an improved gaming experience"
            ) {
                Toggle("", isOn: $bindableAppData.deviceState.lowLatency)
                    .onChange(of: deviceState.lowLatency) { _, isEnabled in
                        nothing.setLowLatency(isEnabled)
                        AppLogger.settings.uiSettingChanged("Low Latency Mode", value: isEnabled)
                    }
                    .disabled(!deviceState.isConnected)
            }

            SettingsRow(
                title: "Over-ear detection",
                description: "Automatically play audio when headphones are in and pause when removed"
            ) {
                Toggle("", isOn: $bindableAppData.deviceState.inEarDetection)
                    .onChange(of: deviceState.inEarDetection) { _, isEnabled in
                        nothing.setInEarDetection(isEnabled)
                        AppLogger.settings.uiSettingChanged("Over-ear Detection", value: isEnabled)
                    }
                    .disabled(!deviceState.isConnected)
            }

            if let model = deviceState.model,
               model.supportsRingBuds,
               let ringBuds = deviceState.ringBuds {
                SettingsRow(
                    title: "Find my headphones",
                    description: "Trigger a loud sound to find your headphones"
                ) {
                    ringButtons(current: ringBuds)
                        .disabled(!deviceState.isConnected)
                }
            }

        }
        .alert(isPresented: $showRingBudsAlert) {
            Alert(
                title: Text("Volume Warning"),
                message: Text("Your headphones may be in use. Be sure to remove them from your ears before you continue.\n\nA loud sound will be played which could be uncomfortable for anyone who is wearing them."),
                primaryButton: .default(Text("Play")) {
                    if let pendingRingBuds {
                        setRingBuds(pendingRingBuds)
                    }
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }

    @ViewBuilder
    private func ringButtons(current: RingBuds) -> some View {
        switch current.bud {
            case .left:
                HStack(spacing: 6) {
                    ringButton(current)
                    ringButton(.init(isOn: false, bud: .right))
                        .disabled(current.isOn)
                }
            case .right:
                HStack(spacing: 6) {
                    ringButton(.init(isOn: false, bud: .left))
                        .disabled(current.isOn)
                    ringButton(current)
                }
            case .unibody:
                ringButton(current)
        }
    }

    @ViewBuilder
    private func ringButton(_ value: RingBuds) -> some View {
        let systemImage = value.isOn ? "stop.fill" : "play.fill"
        Button(value.title, systemImage: systemImage) {
            if value.isOn {
                setRingBuds(.init(isOn: false, bud: value.bud))
            } else {
                pendingRingBuds = .init(isOn: true, bud: value.bud)
                showRingBudsAlert = true
            }
        }
    }

    private func setRingBuds(_ ringBuds: RingBuds) {
        deviceState.ringBuds = ringBuds
        nothing.setRingBuds(ringBuds)
    }
}

private extension DeviceState {

    var isUnibody: Bool {
        switch battery {
            case .budsWithCase:
                return false
            default:
                return true
        }
    }
}

private extension RingBuds {

    var title: String {
        let prefix = isOn ? "Stop" : "Play"
        let suffix = switch bud {
            case .left: " Left"
            case .right: " Right"
            case .unibody: ""
        }
        return "\(prefix)\(suffix)"
    }
}
