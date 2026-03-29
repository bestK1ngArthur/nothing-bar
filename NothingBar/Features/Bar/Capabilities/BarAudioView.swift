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
            volumeView
            
            if let model = deviceState.model, model.supportsEnhancedBass {
                enhancedBassView
                    .disabled(deviceState.enhancedBass == nil)
            }

            BarAudioEQView()
                .disabled(deviceState.eqPreset == nil)
        }
    }

    // MARK: Volume Control

    private var volumeView: some View {
        BarSectionView(
            title: "Volume",
            value: volumeValue
        ) {
            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { appData.systemVolumeController.volume },
                        set: { appData.systemVolumeController.volume = $0 }
                    ),
                    in: 0...1,
                    step: 0.01
                )
                .tint(.accentColor)
                
                Image(systemName: "speaker.wave.3")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var volumeValue: String {
        "\(Int(appData.systemVolumeController.volume * 100))%"
    }

    private var enhancedBassView: some View {
        BarSectionView(
            title: bassTitle,
            value: enhancedBassValue
        ) {
            VStack(alignment: .center, spacing: 8) {
                HStack(spacing: 8) {
                    Text("Off")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Slider(
                        value: .init(
                            get: {
                                Double(deviceState.enhancedBass?.isEnabled ?? false ? deviceState.enhancedBass?.level ?? 1 : 0)
                            },
                            set: { newValue in
                                let level = Int(newValue)
                                if level == 0 {
                                    let settings = EnhancedBass(isEnabled: false, level: 1)
                                    setEnhancedBassSettings(settings)
                                } else {
                                    let settings = EnhancedBass(isEnabled: true, level: level)
                                    setEnhancedBassSettings(settings)
                                }
                            }
                        ),
                        in: 0...5,
                        step: 1
                    )
                    .tint(.accentColor)
                    
                    Text("Lv5")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .disabled(deviceState.enhancedBass == nil)
        }
    }
    
    private var enhancedBassValue: String {
        guard let enhancedBass = deviceState.enhancedBass else {
            return "N/A"
        }
        return enhancedBass.isEnabled ? "Level \(enhancedBass.level)" : "Off"
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
            case .headphone1, .headphoneA:
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
