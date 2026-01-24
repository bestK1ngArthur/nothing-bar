//
//  BarAudioEQView.swift
//  NothingBar
//
//  Created by Artem Belkov on 24.01.2026.
//

import SwiftNothingEar
import SwiftUI

struct BarAudioEQView: View {

    @Environment(AppData.self) var appData
    @State private var isEditingCustomEQ: Bool = false

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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

                if deviceState.eqPreset == .custom {
                    eqCustomControls
                }
            }

            if deviceState.eqPreset == .custom, isEditingCustomEQ {
                eqCustomSliders
            }
        }
        .padding(.horizontal, 4)
        .onChange(of: deviceState.eqPreset) { _, newValue in
            if newValue != .custom {
                isEditingCustomEQ = false
            }
        }
        .animation(.easeInOut, value: deviceState.eqPresetCustom)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Equalizer")
                .font(.subheadline)
                .foregroundColor(.primary)

            eqPresetMenu(currentPreset: deviceState.eqPreset ?? .balanced)
                .fixedSize()
                .padding(.leading, -4)
        }
    }

    private var eqCustomControls: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                if !isEditingCustomEQ {
                    eqCustomValues
                }

                Button(isEditingCustomEQ ? "Done" : "Edit") {
                    isEditingCustomEQ.toggle()
                }
                .font(.caption)
            }
        }
    }

    private var eqCustomSliders: some View {
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

    private var eqCustomValues: some View {
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

    private var customEQ: EQPresetCustom {
        deviceState.eqPresetCustom ?? EQPresetCustom(bass: 0, mid: 0, treble: 0)
    }

    private func setCustomEQPreset(bass: Int? = nil, mid: Int? = nil, treble: Int? = nil) {
        let current = customEQ
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

    private func eqPresetMenu(currentPreset: EQPreset) -> some View {
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

    private var supportedEqPresets: [EQPreset] {
        guard let model = deviceState.model else {
            return []
        }

        return EQPreset.allSupported(by: model)
    }
}
