//
//  BarAudioView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import SwiftNothingEar

struct BarAudioView: View {

    @Environment(AppData.self) var appData

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: NothingEar.Device {
        appData.nothing
    }

    var body: some View {
        VStack(spacing: 12) {
            if deviceState.model.supportsEnhancedBass {
                enhancedBassView
                    .disabled(deviceState.enhancedBass == nil)
            }

            eqView
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
                        let settings = NothingEar.EnhancedBassSettings(
                            isEnabled: isEnabled,
                            level: deviceState.enhancedBass?.level ?? 1
                        )
                        nothing.setEnhancedBass(settings)
                        deviceState.enhancedBass = settings

                        AppLogger.audio.uiSettingChanged("Bass Enhancement", value: isEnabled)

                    }
                )
            )
            .toggleStyle(SwitchToggleStyle())
            .scaleEffect(0.8)
        }
        .padding(.horizontal, 4)

    }

    private func enhancedBassMenu(currentLevel: Int) -> some View {
        Menu {
            ForEach(1...5, id: \.self) { level in
                Button {
                    let settings = NothingEar.EnhancedBassSettings(isEnabled: true, level: level)
                    nothing.setEnhancedBass(settings)
                    deviceState.enhancedBass = settings
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

    // MARK: Equalizer

    private var eqView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Equalizer")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                eqPresetMenu(currentPreset: deviceState.eqPreset ?? .balanced)
                    .fixedSize()
                    .padding(.leading, -4)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private func eqPresetMenu(currentPreset: NothingEar.EQPreset) -> some View {
        Menu {
            ForEach(supportedEqPresets, id: \.self) { preset in
                Button {
                    nothing.setEQPreset(preset)
                    deviceState.eqPreset = preset
                } label: {
                    Text(preset.displayName) + (currentPreset == preset ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
                }
            }
        } label: {
            Text(deviceState.eqPreset?.displayName ?? "Unknown")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }

    private var supportedEqPresets: [NothingEar.EQPreset] {
        var presets: [NothingEar.EQPreset] = [
            .balanced,
            .voice,
            .moreTreble,
            .moreBass
        ]

        if deviceState.model.supportsCustomEQ {
            presets.append(.custom)
        }

        return presets
    }
}

private extension NothingEar.EnhancedBassSettings {

    var displayValue: String {
        guard isEnabled else {
            return "Off"
        }

        return "Level \(level)"
    }
}
