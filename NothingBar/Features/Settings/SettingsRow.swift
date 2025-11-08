//
//  SettingsRow.swift
//  NothingBar
//
//  Created by Artem Belkov on 08.11.2025.
//

import SwiftUI

struct SettingsRow<Value: View>: View {

    let title: String
    let description: String
    let value: () -> Value

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: true, vertical: false)
            }

            Spacer()

            value()
        }
    }
}
