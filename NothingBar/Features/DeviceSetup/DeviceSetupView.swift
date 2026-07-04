//
//  DeviceSetupView.swift
//  NothingBar
//
//  Created by Artem Belkov on 04.07.2026.
//

import Perception
import SwiftUI

struct DeviceSetupView: View {

    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) private var dismiss

    @State private var selectedID: String?

    private let columns = [
        GridItem(.adaptive(minimum: 132, maximum: 160), spacing: 10)
    ]

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                header
                selectionGrid
                Divider()
                footer
            }
            .frame(width: 620, height: 560)
            .onAppear {
                selectedID = initialSelectionID
            }
            .onChange(of: appData.deviceSetupState.context) { _ in
                selectedID = initialSelectionID
            }
            .onDisappear {
                appData.cancelDeviceSetup()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(headerTitle)
                .font(.title2)
                .fontWeight(.semibold)

            if let detectedModel = appData.deviceSetupState.context?.detectedModel {
                Text("Detected as \(detectedModel.displayName). This choice is saved for this device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Choose the exact model and color for this device.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    private var selectionGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(DeviceModelCatalog.all) { selection in
                    DeviceModelSelectionCard(
                        selection: selection,
                        isSelected: selectedID == selection.id
                    ) {
                        selectedID = selection.id
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
            .padding(.bottom, 16)
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if let selectedSelection {
                selectedSummary(for: selectedSelection)
            }

            Spacer()

            Button("Cancel") {
                appData.cancelDeviceSetup()
                dismiss()
            }
            .keyboardShortcut(.cancelAction)

            Button("Save") {
                guard let selectedSelection else { return }

                appData.applyDeviceModelSelection(selectedSelection)
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(selectedSelection == nil)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.bar)
    }

    private var headerTitle: String {
        switch appData.deviceSetupState.context?.mode {
            case .editSelection:
                "Change model and color"
            case .newDevice, .none:
                "New Nothing headphones connected"
        }
    }

    private func selectedSummary(for selection: DeviceModelSelection) -> some View {
        HStack(spacing: 8) {
            Text("Selected:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Circle()
                .fill(selection.swatchColor)
                .overlay {
                    Circle()
                        .stroke(.quaternary, lineWidth: 1)
                }
                .frame(width: 11, height: 11)

            Text("\(selection.displayName) · \(selection.colorName)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }

    private var initialSelectionID: String? {
        if let model = appData.deviceState.model,
           let selection = DeviceModelSelection.selection(for: model) {
            return selection.id
        }

        if let model = appData.deviceSetupState.context?.detectedModel,
           let selection = DeviceModelSelection.selection(for: model) {
            return selection.id
        }

        return DeviceModelCatalog.all.first?.id
    }

    private var selectedSelection: DeviceModelSelection? {
        guard let selectedID else { return nil }

        return DeviceModelSelection.selection(for: selectedID)
    }
}

private struct DeviceModelSelectionCard: View {

    let selection: DeviceModelSelection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    deviceImage
                        .frame(height: 58)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                }

                VStack(spacing: 2) {
                    Text(selection.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(minHeight: 32)

                    HStack(spacing: 5) {
                        Circle()
                            .fill(selection.swatchColor)
                            .overlay {
                                Circle()
                                    .stroke(.quaternary, lineWidth: 1)
                            }
                            .frame(width: 10, height: 10)

                        Text(selection.colorName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 138)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var deviceImage: some View {
        DeviceImageView(deviceImage: selection.deviceImage)
    }
}

private extension DeviceModelSelection {

    var swatchColor: Color {
        switch colorName {
            case "Black", "Dark Grey":
                Color(nsColor: .darkGray)
            case "Grey", "Light Grey":
                Color(nsColor: .lightGray)
            case "White":
                Color.white
            case "Orange":
                Color.orange
            case "Yellow":
                Color.yellow
            case "Blue":
                Color.blue
            case "Pink":
                Color.pink
            case "Light Green":
                Color.green.opacity(0.65)
            default:
                Color.secondary
        }
    }
}
