//
//  SettingsDeviceToolsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
import SwiftNothingEar
import SwiftUI

struct SettingsDeviceToolsView: View {

    @Environment(AppData.self) private var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var bindableDeviceState = deviceState
            let deviceIdentity = deviceState.deviceIdentity
            let isConnected = deviceState.isConnected
            let lowLatency = deviceState.lowLatency
            let inEarDetection = deviceState.inEarDetection
            let model = deviceState.model
            let ringBuds = deviceState.ringBuds

            Group {
                SettingsRow(
                    title: "Model and color",
                    description: "Change the saved model selection for this device"
                ) {
                    Button("Change") {
                        appData.requestCurrentDeviceSetup()
                    }
                    .disabled(deviceIdentity == nil)
                }

                SettingsRow(
                    title: "Low lag mode",
                    description: "Minimise latency for an improved gaming experience"
                ) {
                    Toggle("", isOn: $bindableDeviceState.lowLatency)
                        .onChange(of: lowLatency) { isEnabled in
                            nothing.setLowLatency(isEnabled)
                            AppLogger.settings.uiSettingChanged("Low Latency Mode", value: isEnabled)
                        }
                        .disabled(!isConnected)
                }

                SettingsRow(
                    title: "Over-ear detection",
                    description: "Automatically play audio when headphones are in and pause when removed"
                ) {
                    Toggle("", isOn: $bindableDeviceState.inEarDetection)
                        .onChange(of: inEarDetection) { isEnabled in
                            nothing.setInEarDetection(isEnabled)
                            AppLogger.settings.uiSettingChanged("Over-ear Detection", value: isEnabled)
                        }
                        .disabled(!isConnected)
                }

                if let model, model.supportsRingBuds {
                    SettingsRow(
                        title: "Find my headphones",
                        description: "Trigger a loud sound to find your headphones"
                    ) {
                        FindHeadphonesControls(
                            ringBuds: ringBuds ?? defaultRingBuds(for: deviceState.battery),
                            isConnected: isConnected
                        ) { ringBuds in
                            deviceState.ringBuds = ringBuds
                            nothing.setRingBuds(ringBuds)
                        }
                    }
                }
            }
        }
    }

    private func defaultRingBuds(for battery: Battery?) -> RingBuds {
        switch battery {
            case .budsWithCase:
                .init(isOn: false, bud: .left)
            default:
                .init(isOn: false, bud: .unibody)
        }
    }
}
