//
//  BarAudioEQView.swift
//  NothingBar
//
//  Created by Artem Belkov on 24.01.2026.
//

import Perception
import SwiftNothingEar
import SwiftUI

struct BarAudioEQView: View {

    @Environment(AppData.self) var appData
    @State private var isEditingCustomEQ: Bool = false

    let supportedEqPresets: [EQPreset]

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        WithPerceptionTracking {
            let eqPreset = deviceState.eqPreset
            let eqPresetCustom = deviceState.eqPresetCustom
            let customEQ = eqPresetCustom ?? EQPresetCustom(bass: 0, mid: 0, treble: 0)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    header(
                        currentPreset: eqPreset ?? .balanced,
                        supportedEqPresets: supportedEqPresets
                    )

                    Spacer()

                    if eqPreset == .custom {
                        eqCustomControls(customEQ: customEQ)
                    }
                }

                if eqPreset == .custom, isEditingCustomEQ {
                    eqCustomSliders(customEQ: customEQ)
                }
            }
            .padding(.horizontal, 4)
            .onChange(of: eqPreset) { newValue in
                if newValue != .custom {
                    isEditingCustomEQ = false
                }
            }
            .animation(.easeInOut, value: eqPresetCustom)
        }
    }

    private func header(
        currentPreset: EQPreset,
        supportedEqPresets: [EQPreset]
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Equalizer")
                .font(.subheadline)
                .foregroundColor(.primary)

            eqPresetMenu(
                currentPreset: currentPreset,
                supportedEqPresets: supportedEqPresets
            )
                .fixedSize()
                .padding(.leading, -4)
        }
    }

    private func eqCustomControls(customEQ: EQPresetCustom) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                if !isEditingCustomEQ {
                    eqCustomValues(customEQ: customEQ)
                }

                Button(isEditingCustomEQ ? "Done" : "Edit") {
                    isEditingCustomEQ.toggle()
                }
                .font(.caption)
            }
        }
    }

    private func eqCustomSliders(customEQ: EQPresetCustom) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            eqSlider(
                title: "Bass",
                value: .init(
                    get: { customEQ.bass },
                    set: { newValue in
                        setCustomEQPreset(bass: newValue)
                    }
                )
            )

            eqSlider(
                title: "Mid",
                value: .init(
                    get: { customEQ.mid },
                    set: { newValue in
                        setCustomEQPreset(mid: newValue)
                    }
                )
            )

            eqSlider(
                title: "Treble",
                value: .init(
                    get: { customEQ.treble },
                    set: { newValue in
                        setCustomEQPreset(treble: newValue)
                    }
                )
            )
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func eqCustomValues(customEQ: EQPresetCustom) -> some View {
        HStack(spacing: 6) {
            Text("Bass \(formatEQValue(customEQ.bass))")
            Text("Mid \(formatEQValue(customEQ.mid))")
            Text("Treble \(formatEQValue(customEQ.treble))")
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }

    private func eqSlider(title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formatEQValue(value.wrappedValue))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 18, alignment: .trailing)
            }

            Slider(
                value: .init(
                    get: { Double(value.wrappedValue) },
                    set: { newValue in
                        value.wrappedValue = Int(newValue)
                    }
                ),
                in: -6...6,
                step: 1
            )
            .frame(width: 140)
        }
    }

    private func setCustomEQPreset(bass: Int? = nil, mid: Int? = nil, treble: Int? = nil) {
        let current = deviceState.eqPresetCustom ?? EQPresetCustom(bass: 0, mid: 0, treble: 0)
        let updated = EQPresetCustom(
            bass: bass ?? current.bass,
            mid: mid ?? current.mid,
            treble: treble ?? current.treble
        )
        nothing.setCustomEQPreset(updated)
        deviceState.eqPresetCustom = updated
        AppLogger.audio.uiSettingChanged("EQ Custom", value: "\(updated.bass), \(updated.mid), \(updated.treble)")
    }

    private func formatEQValue(_ value: Int) -> String {
        value > 0 ? "+\(value)" : "\(value)"
    }

    private func eqPresetMenu(
        currentPreset: EQPreset,
        supportedEqPresets: [EQPreset]
    ) -> some View {
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
            Text(currentPreset.displayName)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}
