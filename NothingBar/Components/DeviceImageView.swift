//
//  DeviceImageView.swift
//  NothingBar
//
//  Created by Artem Belkov on 14.08.2025.
//

import SwiftNothingEar
import SwiftUI

struct DeviceImageView: View {

    let deviceImage: DeviceModel.DeviceImage
    let budsOverlapRatio: CGFloat

    init(deviceImage: DeviceModel.DeviceImage, budsOverlapRatio: CGFloat = 0.25) {
        self.deviceImage = deviceImage
        self.budsOverlapRatio = budsOverlapRatio
    }

    var body: some View {
        switch deviceImage {
            case let .buds(left, right):
                budsImageView(left: left, right: right)
            case let .single(image):
                imageView(image)
        }
    }

    private func budsImageView(left: ImageResource, right: ImageResource) -> some View {
        GeometryReader { proxy in
            let spacing = budsSpacing(for: proxy.size)
            let imageSize = budsImageSize(in: proxy.size, spacing: spacing)

            HStack(spacing: spacing) {
                imageView(left)
                    .frame(width: imageSize, height: imageSize)

                imageView(right)
                    .frame(width: imageSize, height: imageSize)
            }
            .frame(width: imageSize * 2 + spacing, height: imageSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func imageView(_ image: ImageResource) -> some View {
        Image(image)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
    }

    private func budsSpacing(for size: CGSize) -> CGFloat {
        -min(size.width, size.height) * budsOverlapRatio
    }

    private func budsImageSize(in size: CGSize, spacing: CGFloat) -> CGFloat {
        min(size.height, max(0, (size.width - spacing) / 2))
    }
}

extension DeviceModel {

    enum DeviceImage {
        case buds(left: ImageResource, right: ImageResource)
        case single(ImageResource)
    }

    var deviceImage: DeviceImage? {
        DeviceModelCatalog.selection(for: self)?.deviceImage
    }
}
