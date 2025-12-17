//
//  DeviceImageView.swift
//  NothingBar
//
//  Created by Artem Belkov on 14.08.2025.
//

import SwiftNothingEar
import SwiftUI

struct DeviceImageView: View {

    let deviceImage: NothingEar.Model.DeviceImage

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

extension NothingEar.Model {

    enum DeviceImage {
        case buds(left: ImageResource, right: ImageResource)
        case single(ImageResource)
    }

    var deviceImage: DeviceImage? {
        switch self {
            case .ear1(.black):
                .buds(left: .ear1BlackLeft, right: .ear1BlackRight)
            case .ear1(.white):
                .buds(left: .ear1WhiteLeft, right: .ear1WhiteRight)
            case .ear2(.black):
                .buds(left: .ear2BlackLeft, right: .ear2BlackRight)
            case .ear2(.white):
                .buds(left: .ear2WhiteLeft, right: .ear2WhiteRight)
            case .ear3(.black):
                .buds(left: .ear3BlackLeft, right: .ear3BlackRight)
            case .ear3(.white):
                .buds(left: .ear3WhiteLeft, right: .ear3WhiteRight)
            case .earStick:
                .buds(left: .earStickLeft, right: .earStickRight)
            case .earOpen:
                .buds(left: .earOpenLeft, right: .earOpenRight)
            case .ear(.black):
                .buds(left: .earBlackLeft, right: .earBlackRight)
            case .ear(.white):
                .buds(left: .earWhiteLeft, right: .earWhiteRight)
            case .earA(.black):
                .buds(left: .earABlackLeft, right: .earABlackRight)
            case .earA(.white):
                .buds(left: .earAWhiteLeft, right: .earAWhiteRight)
            case .earA(.yellow):
                .buds(left: .earAYellowLeft, right: .earAYellowRight)
            case .headphone1(.black):
                .single(.headphone1Black)
            case .headphone1(.grey):
                .single(.headphone1Grey)
            case .cmfBudsPro(.black):
                .buds(left: .cmfBudsProBlackLeft, right: .cmfBudsProBlackRight)
            case .cmfBudsPro(.orange):
                .buds(left: .cmfBudsProOrangeLeft, right: .cmfBudsProOrangeRight)
            case .cmfBudsPro(.white):
                .buds(left: .cmfBudsProWhiteLeft, right: .cmfBudsProWhiteRight)
            case .cmfBuds(.black):
                .buds(left: .cmfBudsBlackLeft, right: .cmfBudsBlackRight)
            case .cmfBuds(.orange):
                .buds(left: .cmfBudsOrangeLeft, right: .cmfBudsOrangeRight)
            case .cmfBuds(.white):
                .buds(left: .cmfBudsWhiteLeft, right: .cmfBudsWhiteRight)
            case .cmfBuds2(.lightGreen):
                .buds(left: .cmfBuds2GreenLeft, right: .cmfBuds2GreenRight)
            case .cmfBuds2(.orange):
                .buds(left: .cmfBuds2OrangeLeft, right: .cmfBuds2OrangeRight)
            case .cmfBuds2(.darkGrey):
                .buds(left: .cmfBuds2BlackLeft, right: .cmfBuds2BlackRight)
            case .cmfBudsPro2(.black):
                .buds(left: .cmfBudsPro2BlackLeft, right: .cmfBudsPro2BlackRight)
            case .cmfBudsPro2(.blue):
                .buds(left: .cmfBudsPro2BlueLeft, right: .cmfBudsPro2BlueRight)
            case .cmfBudsPro2(.orange):
                .buds(left: .cmfBudsPro2OrangeLeft, right: .cmfBudsPro2OrangeRight)
            case .cmfBudsPro2(.white):
                .buds(left: .cmfBudsPro2WhiteLeft, right: .cmfBudsPro2WhiteRight)
            case .cmfNeckbandPro(.black):
                .single(.cmfNeckbandProBlack)
            case .cmfNeckbandPro(.orange):
                .single(.cmfNeckbandProOrange)
            case .cmfNeckbandPro(.white):
                .single(.cmfNeckbandProWhite)
            case .cmfHeadphonePro(.darkGrey):
                .single(.cmfHeadphonePro1DarkGrey)
            case .cmfHeadphonePro(.lightGreen):
                .single(.cmfHeadphonePro1LightGreen)
            case .cmfHeadphonePro(.lightGrey):
                .single(.cmfHeadphonePro1LightGrey)
        }
    }
}
