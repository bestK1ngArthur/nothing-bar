//
//  NotificationStyleCard.swift
//  NothingBar
//
//  Created by Artem Belkov on 22.02.2026.
//

import SwiftUI

struct NotificationStyleCard: View {

    let style: NotificationStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(style.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 10)

                    if isSelected {
                        Label("Selected", systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.semibold))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(Color.accentColor)
                    }
                }

                Text(style.descriptionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(style.placementText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                NotificationStylePreview(style: style)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor.opacity(0.9) : Color.secondary.opacity(0.25), lineWidth: isSelected ? 2 : 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(style.displayName)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(style.placementText)
    }
}
