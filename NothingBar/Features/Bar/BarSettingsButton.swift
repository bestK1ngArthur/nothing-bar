//
//  BarSettingsButton.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import SwiftUI
import AppKit

struct BarSettingsButton: View {

    @Environment(\.openSettings) private var openSettings

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
        openSettings()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
            if let settingsWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
                settingsWindow.makeKeyAndOrderFront(nil)
                settingsWindow.orderFrontRegardless()
            }
        }
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
