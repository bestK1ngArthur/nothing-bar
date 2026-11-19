//
//  BarMenuLabel.swift
//  NothingBar
//
//  Created by Artem Belkov on 06.10.2026.
//

import Perception
import SwiftUI

/// Value label for the compact menus in the bar. It draws its own chevron in the value's color.
struct BarMenuLabel: View {

    let title: String

    var body: some View {
        (Text(title) + Text(" ") + Text(Image(systemName: "chevron.down")).font(.caption2.weight(.semibold)))
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

/// A compact dropdown for the bar that lists its choices in a popover.
///
/// Pop-up menus opened from the bar panel don't appear over another app's full-screen space,
/// even when the app is active. The popover is a child window of the panel, so it does.
struct BarPopoverPicker<Content: View>: View {

    @Environment(AppData.self) private var appData
    @State private var isPresented = false

    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        WithPerceptionTracking {
            Button {
                isPresented.toggle()
            } label: {
                BarMenuLabel(title: title)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPresented, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(6)
                .frame(minWidth: 200)
            }
            // The popover is a child of the panel, so it would reappear when the panel opens again.
            .onChange(of: appData.isBarVisible) { isVisible in
                if !isVisible { isPresented = false }
            }
        }
    }
}

/// A titled group of rows in a `BarPopoverPicker`.
struct BarPickerSection<Content: View>: View {

    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

/// A menu-like row in a `BarPopoverPicker`: highlighted on hover, with a checkmark for the
/// current choice. Choosing it closes the popover.
struct BarPickerRow: View {

    @Environment(\.dismiss) private var dismiss
    @State private var isHovered = false

    let title: Text
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            dismiss()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.semibold))
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(true)
                title
                Spacer(minLength: 12)
            }
            .font(.body)
            .foregroundStyle(isHovered ? Color.white : Color.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isHovered ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
