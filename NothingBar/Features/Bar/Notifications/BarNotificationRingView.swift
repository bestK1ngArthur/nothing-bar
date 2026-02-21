//
//  BarNotificationRingView.swift
//  NothingBar
//
//  Created by Artem Belkov on 21.02.2026.
//

import SwiftUI

struct BarNotificationRingView: View {

    enum Size {
        case small
        case medium
    }

    let progress: Double
    let isConnected: Bool
    let size: Size

    private var color: Color {
        if isConnected {
            return progress > 0.2 ? .green : .red
        }

        return .secondary
    }

    var body: some View {
        ZStack {
            if progress > 0 {
                Text("\(Int((progress * 100).rounded()))")
                    .font(.system(size: size.fontSize, weight: .bold))
                    .foregroundColor(.primary)
            }

            Circle()
                .stroke(lineWidth: size.lineWidth)
                .opacity(0.1)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(
                    style: StrokeStyle(
                        lineWidth: size.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut, value: progress)
        }
        .frame(width: size.frameSize, height: size.frameSize)
    }
}

private extension BarNotificationRingView.Size {

    var lineWidth: CGFloat {
        switch self {
            case .small:
                return 3
            case .medium:
                return 4
        }
    }

    var fontSize: CGFloat {
        switch self {
            case .small:
                return 10
            case .medium:
                return 12
        }
    }

    var frameSize: CGFloat {
        switch self {
            case .small:
                return 26
            case .medium:
                return 32
        }
    }
}
