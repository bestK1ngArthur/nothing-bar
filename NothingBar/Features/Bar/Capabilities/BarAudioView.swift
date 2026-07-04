//
//  BarAudioView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import Perception
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
        WithPerceptionTracking {
            let model = deviceState.model
            let enhancedBass = deviceState.enhancedBass
            let eqPreset = deviceState.eqPreset
            let spatialAudioMode = deviceState.spatialAudioMode
            let supportedEqPresets = model.map(EQPreset.allSupported(by:)) ?? []

            VStack(spacing: 12) {
                if let model, model.supportsEnhancedBass {
                    enhancedBassView(
                        model: model,
                        enhancedBass: enhancedBass,
                        spatialAudioMode: spatialAudioMode
                    )
                        .disabled(enhancedBass == nil)
                }

                BarAudioEQView(supportedEqPresets: supportedEqPresets)
                    .disabled(eqPreset == nil)
            }
        }
    }

    private func enhancedBassView(
        model: DeviceModel,
        enhancedBass: EnhancedBass?,
        spatialAudioMode: SpatialAudioMode?
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bassTitle(for: model))
                    .font(.subheadline)
                    .foregroundColor(.primary)

                enhancedBassMenu(
                    model: model,
                    enhancedBass: enhancedBass,
                    spatialAudioMode: spatialAudioMode
                )
                    .fixedSize()
                    .padding(.leading, -4)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private func enhancedBassValue(for enhancedBass: EnhancedBass?) -> String {
        guard let enhancedBass else {
            return "N/A"
        }

        return enhancedBass.isEnabled ? "Level \(enhancedBass.level)" : "Off"
    }

    private func enhancedBassMenu(
        model: DeviceModel,
        enhancedBass: EnhancedBass?,
        spatialAudioMode: SpatialAudioMode?
    ) -> some View {
        let value = enhancedBassValue(for: enhancedBass)

        return Menu {
            Button {
                setEnhancedBassSettings(
                    .init(isEnabled: false, level: 1),
                    model: model,
                    spatialAudioMode: spatialAudioMode
                )
            } label: {
                Text("Off") + (value == "Off" ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
            }

            ForEach(1...5, id: \.self) { level in
                Button {
                    setEnhancedBassSettings(
                        .init(isEnabled: true, level: level),
                        model: model,
                        spatialAudioMode: spatialAudioMode
                    )
                } label: {
                    let isSelected = enhancedBass?.isEnabled == true && enhancedBass?.level == level
                    Text("Level \(level)") + (isSelected ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
                }
            }
        } label: {
            Text(value)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }

    private func isCompatibleWithSpatialAudio(model: DeviceModel) -> Bool {
        return SpatialAudioMode.isCompatibleWithEnhancedBass(by: model)
    }

    private func setEnhancedBassSettings(
        _ settings: EnhancedBass,
        model: DeviceModel,
        spatialAudioMode: SpatialAudioMode?
    ) {
        // Enhanced bass and spatial audio can't work simultaneously for some devices
        if !isCompatibleWithSpatialAudio(model: model),
           settings.isEnabled,
           spatialAudioMode != .off {
            nothing.setSpatialAudioMode(.off)
            deviceState.spatialAudioMode = .off
        }

        nothing.setEnhancedBass(settings)
        deviceState.enhancedBass = settings

        AppLogger.audio.uiSettingChanged("Enhanced Bass", value: settings.displayValue)
    }

    private func bassTitle(for model: DeviceModel) -> String {
        // Check if it's a headphone (over-ear) or earbuds (in-ear)
        switch model {
            case .headphone1, .headphoneA, .cmfHeadphonePro:
                return "Bass Enhancement"
            default:
                return "Ultra Bass"
        }
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
