//
//  SettingsDeviceToolsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar

struct SettingsDeviceToolsView: View {

    @Environment(AppData.self) private var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: NothingEar.Device {
        appData.nothing
    }

    var body: some View {
        @Bindable var bindableAppData = appData

        // Low lag mode
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Low lag mode")
                    .font(.body)
                Text("Minimise latency for an improved gaming experience.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Toggle("", isOn: $bindableAppData.deviceState.lowLatency)
                .onChange(of: deviceState.lowLatency) { _, isEnabled in
                    nothing.setLowLatency(isEnabled)
                    print("Low Latency Mode changed to: \(isEnabled)")
                }
        }

        // Over-ear detection
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Over-ear detection")
                    .font(.body)
                Text("Automatically play audio when headphones are in and pause when removed.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Toggle("", isOn: $bindableAppData.deviceState.inEarDetection)
                .onChange(of: deviceState.inEarDetection) { _, isEnabled in
                    nothing.setInEarDetection(isEnabled)
                    print("Over-ear Detection changed to: \(isEnabled)")
                }
        }
    }
}
