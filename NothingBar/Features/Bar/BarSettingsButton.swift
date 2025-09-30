//
//  BarSettingsButton.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import AppKit
import SwiftUI

struct BarSettingsButton: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button {
            openFocusedSettings()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
        .buttonStyle(HoverButtonStyle())
        .help("Settings")
        .contextMenu {
            Button {
                openFocusedSettings()
            } label: {
                Text("Open Settings")
                Image(systemName: "gearshape.fill")
            }

            Button(role: .destructive) {
                quitApp()
            } label: {
                Text("Quit App")
                Image(systemName: "xmark.circle.fill")
            }
        }
    }

    private func openFocusedSettings() {
        dismiss()
        openWindow(id: "settings")

        guard let window = NSApp.windows.first(where: { $0.title == "Settings" }) else {
            return
        }

        window.collectionBehavior.insert(.moveToActiveSpace)
        window.makeKeyAndOrderFront(nil)

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func quitApp() {
        NSApp.terminate(nil)
    }
}

struct HoverButtonStyle: ButtonStyle {

    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .background(
                Circle()
                    .fill(backgroundColor(configuration: configuration))
            )
            .onHover { hovering in
                isHovering = hovering
            }
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        if configuration.isPressed {
            .secondary.opacity(0.4)
        } else if isHovering {
            .secondary.opacity(0.2)
        } else {
            .clear
        }
    }
}
