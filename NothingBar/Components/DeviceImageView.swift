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

    var body: some View {
        switch deviceImage {
            case let .buds(left, right):
                HStack(spacing: 6) {
                    imageView(left)
                    imageView(right)
                }
            case let .single(image):
                imageView(image)
        }
    }

    private func imageView(_ image: ImageResource) -> some View {
        Image(image)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
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
