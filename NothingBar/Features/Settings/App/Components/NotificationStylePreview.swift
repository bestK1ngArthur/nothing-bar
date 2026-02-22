//
//  NotificationStylePreview.swift
//  NothingBar
//
//  Created by Artem Belkov on 22.02.2026.
//

import SwiftUI

struct NotificationStylePreview: View {

    let style: NotificationStyle

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.12))

            switch style {
                case .classic:
                    notificationBubble(size: .classic)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(.top, 6)
                        .padding(.trailing, 4)

                case .apple:
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.22))
                                .frame(height: 12)

                            Capsule()
                                .fill(.secondary.opacity(0.5))
                                .frame(width: 6, height: 6)
                        }
                        .padding(.horizontal, 6)
                        .padding(.top, 6)

                        Spacer()
                            .frame(height: 6)

                        notificationBubble(size: .apple)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .frame(height: 82)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func notificationBubble(size: PreviewSize) -> some View {
        HStack(spacing: size.iconSpacing) {
            Circle()
                .fill(.secondary.opacity(0.25))
                .overlay {
                    Image(systemName: "headphones")
                        .font(.system(size: size.iconFont, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(width: size.iconContainer, height: size.iconContainer)

            VStack(alignment: size.textAlignment, spacing: 2) {
                Text("Headphones")
                    .font(.system(size: size.titleFont, weight: .semibold))
                    .lineLimit(1)

                Text("Connected")
                    .font(.system(size: size.subtitleFont, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: size.contentAlignment)

            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.2), lineWidth: 2)

                Circle()
                    .trim(from: 0, to: 0.85)
                    .stroke(.green, style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: size.ringSize, height: size.ringSize)
        }
        .padding(size.padding)
        .frame(maxWidth: size.maxWidth)
        .background {
            Capsule()
                .fill(.regularMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                }
        }
    }
}

private extension NotificationStylePreview {

    enum PreviewSize {
        case classic
        case apple

        var maxWidth: CGFloat {
            switch self {
                case .classic: 152
                case .apple: 128
            }
        }

        var padding: CGFloat {
            switch self {
                case .classic: 7
                case .apple: 6
            }
        }

        var iconContainer: CGFloat {
            switch self {
                case .classic: 18
                case .apple: 14
            }
        }

        var iconFont: CGFloat {
            switch self {
                case .classic: 10
                case .apple: 8
            }
        }

        var iconSpacing: CGFloat {
            switch self {
                case .classic: 6
                case .apple: 5
            }
        }

        var titleFont: CGFloat {
            switch self {
                case .classic: 9
                case .apple: 7
            }
        }

        var subtitleFont: CGFloat {
            switch self {
                case .classic: 8
                case .apple: 6
            }
        }

        var textAlignment: HorizontalAlignment {
            switch self {
                case .classic: .leading
                case .apple: .center
            }
        }

        var contentAlignment: Alignment {
            switch self {
                case .classic: .leading
                case .apple: .center
            }
        }

        var ringSize: CGFloat {
            switch self {
                case .classic: 16
                case .apple: 14
            }
        }
    }
}
