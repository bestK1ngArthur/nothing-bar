//
//  CirclePickerView.swift
//  NothingBar
//
//  Created by Artem Belkov on 28.09.2025.
//

import SwiftUI

struct ModeCircleView<Overlay: View>: View {

    let image: ImageResource
    let name: String
    let isActive: Bool

    let onTap: () -> Void
    let overlay: (() -> Overlay)?

    init(
        image: ImageResource,
        name: String,
        isActive: Bool,
        onTap: @escaping () -> Void,
        overlay: (() -> Overlay)? = nil
    ) {
        self.image = image
        self.name = name
        self.isActive = isActive
        self.onTap = onTap
        self.overlay = overlay
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                circleView
                    .frame(width: 60, height: 60)
                    .overlay(alignment: .topTrailing) {
                        if let overlay {
                            overlay()
                        }
                    }

                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 70)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var circleView: some View {
        ZStack {
            Circle()
                .fill(isActive ? Color.accentColor : Color.secondary)
                .frame(width: 44, height: 44)

            Image(image)
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : .primary)
        }
    }
}
