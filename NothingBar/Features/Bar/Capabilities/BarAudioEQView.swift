//
//  BarAudioEQView.swift
//  NothingBar
//
//  Created by Artem Belkov on 24.01.2026.
//

import Perception
import SwiftNothingEar
import SwiftUI

private struct EQQuickProfile: Identifiable {
    let id: String
    let name: String
    let values: EQPresetCustom
}

struct BarAudioEQView: View {

    @Environment(AppData.self) var appData
    @State private var currentPreset: EQPreset = .balanced
    @State private var pendingUserPreset: EQPreset?
    @State private var selectedProfileID: String?
    @State private var isEditingCustomEQ: Bool = false

    let supportedEqPresets: [EQPreset]

    private let quickProfiles: [EQQuickProfile] = [
        .init(id: "rock", name: "Rock", values: .init(bass: 3, mid: 1, treble: 2)),
        .init(id: "pop", name: "Pop", values: .init(bass: 2, mid: 0, treble: 1)),
        .init(id: "electronic", name: "Electronic", values: .init(bass: 4, mid: -1, treble: 2)),
        .init(id: "classical", name: "Classical", values: .init(bass: 0, mid: 2, treble: 3)),
        .init(id: "warm", name: "Warm", values: .init(bass: 3, mid: 1, treble: -2)),
        .init(id: "bright", name: "Bright", values: .init(bass: -1, mid: 0, treble: 4)),
        .init(id: "podcast", name: "Podcast", values: .init(bass: -2, mid: 4, treble: 1))
    ]

    private var deviceState: DeviceState {
        appData.deviceState
    }

    private var nothing: Device {
        appData.nothing
    }

    private var standardPresets: [EQPreset] {
        supportedEqPresets.filter { $0 != .advanced }
    }

    var body: some View {
        WithPerceptionTracking {
            let reportedPreset = deviceState.eqPreset
            let eqPresetCustom = deviceState.eqPresetCustom
            let customEQ = eqPresetCustom ?? EQPresetCustom(bass: 0, mid: 0, treble: 0)

            VStack(alignment: .leading, spacing: 12) {
                Text("Equalizer")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                presetSection(
                    title: "Presets",
                    presets: standardPresets
                )

                profileSection

                if currentPreset == .custom {
                    HStack {
                        eqCustomValues(customEQ: customEQ)

                        Spacer()

                        Button(isEditingCustomEQ ? "Done" : "Edit") {
                            isEditingCustomEQ.toggle()
                        }
                        .font(.caption)
                    }

                    if isEditingCustomEQ {
                        eqCustomSliders(customEQ: customEQ)
                    }
                }
            }
            .padding(.horizontal, 4)
            .onAppear {
                syncFromDevice(reportedPreset)
            }
            .onChange(of: reportedPreset) { newValue in
                syncFromDevice(newValue)
            }
            .onChange(of: currentPreset) { newValue in
                if newValue != .custom {
                    isEditingCustomEQ = false
                    selectedProfileID = nil
                }
            }
            .animation(.easeInOut, value: eqPresetCustom)
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profiles")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 72), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(quickProfiles) { profile in
                    presetChip(
                        title: profile.name,
                        isSelected: selectedProfileID == profile.id
                    ) {
                        applyQuickProfile(profile)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func presetSection(title: String, presets: [EQPreset]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 72), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(presets, id: \.self) { preset in
                    presetChip(
                        title: preset.displayName,
                        isSelected: currentPreset == preset && selectedProfileID == nil
                    ) {
                        selectedProfileID = nil
                        setPreset(preset)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func presetChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.18))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func eqCustomSliders(customEQ: EQPresetCustom) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            eqSlider(
                title: "Bass",
                value: .init(
                    get: { customEQ.bass },
                    set: { newValue in
                        selectedProfileID = nil
                        setCustomEQPreset(bass: newValue)
                    }
                )
            )

            eqSlider(
                title: "Mid",
                value: .init(
                    get: { customEQ.mid },
                    set: { newValue in
                        selectedProfileID = nil
                        setCustomEQPreset(mid: newValue)
                    }
                )
            )

            eqSlider(
                title: "Treble",
                value: .init(
                    get: { customEQ.treble },
                    set: { newValue in
                        selectedProfileID = nil
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

    private func applyQuickProfile(_ profile: EQQuickProfile) {
        selectedProfileID = profile.id
        setPreset(.custom)
        setCustomEQPreset(
            bass: profile.values.bass,
            mid: profile.values.mid,
            treble: profile.values.treble
        )
        AppLogger.audio.uiSettingChanged("EQ Profile", value: profile.name)
    }

    private func setPreset(_ preset: EQPreset) {
        guard preset != .advanced else {
            return
        }

        pendingUserPreset = preset
        currentPreset = preset
        nothing.setEQPreset(preset)
        deviceState.eqPreset = preset
        AppLogger.audio.uiSettingChanged("EQ Preset", value: preset.displayName)
    }

    private func syncFromDevice(_ reportedPreset: EQPreset?) {
        guard let reportedPreset else {
            return
        }

        let normalizedPreset = reportedPreset == .advanced ? .balanced : reportedPreset

        if let pendingUserPreset {
            if pendingUserPreset == normalizedPreset {
                self.pendingUserPreset = nil
                currentPreset = normalizedPreset
            }
            return
        }

        currentPreset = normalizedPreset
        selectedProfileID = matchingProfileID(for: deviceState.eqPresetCustom)
    }

    private func matchingProfileID(for customEQ: EQPresetCustom?) -> String? {
        guard let customEQ else {
            return nil
        }

        return quickProfiles.first { $0.values == customEQ }?.id
    }

    private func setCustomEQPreset(bass: Int? = nil, mid: Int? = nil, treble: Int? = nil) {
        let current = deviceState.eqPresetCustom ?? EQPresetCustom(bass: 0, mid: 0, treble: 0)
        let updated = EQPresetCustom(
            bass: bass ?? current.bass,
            mid: mid ?? current.mid,
            treble: treble ?? current.treble
        )

        if currentPreset != .custom {
            setPreset(.custom)
        }

        nothing.setCustomEQPreset(updated)
        deviceState.eqPresetCustom = updated
        AppLogger.audio.uiSettingChanged("EQ Custom", value: "\(updated.bass), \(updated.mid), \(updated.treble)")
    }

    private func formatEQValue(_ value: Int) -> String {
        value > 0 ? "+\(value)" : "\(value)"
    }
}