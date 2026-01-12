//
//  NoDeviceView.swift
//  NothingBar
//
//  Created by Artem Belkov on 12.01.2026.
//

import SwiftUI

struct NoDeviceView: View {

    @Environment(AppData.self) var appData

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "headphones")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Text("No Headphones Found")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("Connect your Nothing headphones using Bluetooth settings on your Mac")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            Button(action: openSettings) {
                HStack(spacing: 6) {
                    Image(systemName: "gear")
                        .font(.system(size: 12, weight: .medium))
                    Text("Open Bluetooth Settings")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.6)
                    .controlSize(.small)
                Text("Waiting for devices...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func openSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.bluetooth")!)
    }
}
