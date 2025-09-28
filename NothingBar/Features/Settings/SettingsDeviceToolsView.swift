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

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: NothingEar.Device {
        appData.nothing
    }

    var body: some View {
        @Bindable var bindableAppData = appData

        HStack {
            text(
                title: "Low lag mode",
                subtitle: "Minimise latency for an improved gaming experience."
            )

            Spacer()

            Toggle("", isOn: $bindableAppData.deviceState.lowLatency)
                .onChange(of: deviceState.lowLatency) { _, isEnabled in
                    nothing.setLowLatency(isEnabled)
                    AppLogger.settings.uiSettingChanged("Low Latency Mode", value: isEnabled)
                }
                .disabled(!deviceState.isConnected)
        }

        HStack {
            text(
                title: "Over-ear detection",
                subtitle: "Automatically play audio when headphones are in and pause when removed."
            )

            Spacer()

            Toggle("", isOn: $bindableAppData.deviceState.inEarDetection)
                .onChange(of: deviceState.inEarDetection) { _, isEnabled in
                    nothing.setInEarDetection(isEnabled)
                    AppLogger.settings.uiSettingChanged("Over-ear Detection", value: isEnabled)
                }
                .disabled(!deviceState.isConnected)
        }
    }

    private func text(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}
