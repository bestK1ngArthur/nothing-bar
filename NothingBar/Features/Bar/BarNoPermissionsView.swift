//
//  BarNoPermissionsView.swift
//  NothingBar
//
//  Created by Artem Belkov on 31.07.2025.
//

import AppKit
import SwiftUI

struct BarNoPermissionsView: View {

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Text("Bluetooth Access Required")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("Please grant Bluetooth permissions in System Settings > Privacy & Security.\n\nIf bluetooth is off, turn it on.")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            VStack(spacing: 8) {
                Button(action: {
                    // Open System Settings > Privacy & Security
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth")!)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "gear")
                            .font(.system(size: 12, weight: .medium))
                        Text("Open Privacy Settings")
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
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topTrailing) {
            BarSettingsButton()
        }
        .padding(16)
    }
}
