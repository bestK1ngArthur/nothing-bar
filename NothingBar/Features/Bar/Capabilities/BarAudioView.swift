//
//  BarAudioView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftNothingEar
import SwiftUI

struct BarAudioView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        VStack(spacing: 12) {
            if let model = deviceState.model, model.supportsEnhancedBass {
                enhancedBassView
                    .disabled(deviceState.enhancedBass == nil)
            }

            BarAudioEQView()
                .disabled(deviceState.eqPreset == nil)
        }
    }

    // MARK: Enhanced Bass

    private var enhancedBassView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bass Enhancement")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                if let enhancedBass = deviceState.enhancedBass, enhancedBass.isEnabled {
                    enhancedBassMenu(currentLevel: enhancedBass.level)
                        .fixedSize()
                        .padding(.leading, -4)
                } else {
                    Text("Off")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Toggle(
                "",
                isOn: .init(
                    get: {
                        deviceState.enhancedBass?.isEnabled ?? false
                    },
                    set: { isEnabled in
                        let settings = EnhancedBass(
                            isEnabled: isEnabled,
                            level: deviceState.enhancedBass?.level ?? 1
                        )
                        setEnhancedBassSettings(settings)
                    }
                )
            )
            .toggleStyle(.switch)
            .padding(.trailing, -8)
            .scaleEffect(0.8)
        }
        .padding(.horizontal, 4)
    }

    private func enhancedBassMenu(currentLevel: Int) -> some View {
        Menu {
            ForEach(1...5, id: \.self) { level in
                Button {
                    let settings = EnhancedBass(isEnabled: true, level: level)
                    setEnhancedBassSettings(settings)
                } label: {
                    Text("Level \(level)") + (currentLevel == level ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
                }
            }
        } label: {
            Text(deviceState.enhancedBass?.displayValue ?? "Unknown")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }

    private var isCompatibleWithSpatialAudio: Bool {
        guard let model = deviceState.model else {
            return false
        }

        return SpatialAudioMode.isCompatibleWithEnhancedBass(by: model)
    }

    private func setEnhancedBassSettings(_ settings: EnhancedBass) {
        // Enhanced bass and spatial audio can't work simultaneously for some devices
        if !isCompatibleWithSpatialAudio,
           settings.isEnabled,
           deviceState.spatialAudioMode != .off {
            nothing.setSpatialAudioMode(.off)
            deviceState.spatialAudioMode = .off
        }

        nothing.setEnhancedBass(settings)
        deviceState.enhancedBass = settings

        AppLogger.audio.uiSettingChanged("Enhanced Bass", value: settings.displayValue)
    }

}

private extension EnhancedBass {

    var displayValue: String {
        guard isEnabled else {
            return "Off"
        }

        return "Level \(level)"
    }
}
