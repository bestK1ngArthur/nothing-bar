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

    private var enhancedBassView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bassTitle)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                enhancedBassMenu
                    .fixedSize()
                    .padding(.leading, -4)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private var enhancedBassValue: String {
        guard let enhancedBass = deviceState.enhancedBass else {
            return "N/A"
        }

        return enhancedBass.isEnabled ? "Level \(enhancedBass.level)" : "Off"
    }

    private var enhancedBassMenu: some View {
        Menu {
            Button {
                setEnhancedBassSettings(.init(isEnabled: false, level: 1))
            } label: {
                Text("Off") + (enhancedBassValue == "Off" ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
            }

            ForEach(1...5, id: \.self) { level in
                Button {
                    setEnhancedBassSettings(.init(isEnabled: true, level: level))
                } label: {
                    let isSelected = deviceState.enhancedBass?.isEnabled == true && deviceState.enhancedBass?.level == level
                    Text("Level \(level)") + (isSelected ? Text(" ") + Text(Image(systemName: "checkmark")) : Text(""))
                }
            }
        } label: {
            Text(enhancedBassValue)
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

    private var bassTitle: String {
        guard let model = deviceState.model else {
            return "Bass Enhancement"
        }

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
