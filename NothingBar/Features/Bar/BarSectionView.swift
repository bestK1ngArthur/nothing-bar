//
//  BarSectionView.swift
//  NothingBar
//
//  Created by Artem Belkov on 02.08.2025.
//

import SwiftUI

struct BarSectionView<Content: View>: View {

    let title: String
    let value: String?

    let content: () -> Content

    var body: some View {
        VStack(spacing: 12) {
            if let value {
                HStack {
                    titleView

                    Spacer()

                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .contentTransition(.opacity)
                        .animation(.easeInOut, value: value)
                }
            } else {
                titleView
            }

            content()
        }
        .padding(.horizontal, 4)
    }

    private var titleView: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
