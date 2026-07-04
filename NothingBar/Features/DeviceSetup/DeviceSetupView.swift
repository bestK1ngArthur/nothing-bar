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
            VStack(alignment: .leading, spacing: 16) {
                header
                selectionGrid
                footer
            }
            .padding(20)
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
            Text("New Nothing headphones connected")
                .font(.title2)
                .fontWeight(.semibold)

            if let detectedModel = appData.deviceSetupState.context?.detectedModel {
                Text("Detected as \(detectedModel.displayName). Confirm the exact model and color.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Confirm the exact model and color.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
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
            .padding(.vertical, 2)
        }
    }

    private var footer: some View {
        HStack {
            if let selectedSelection {
                Text("\(selectedSelection.displayName), \(selectedSelection.colorName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
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
