//
//  DeviceModelSelection.swift
//  NothingBar
//
//  Created by Artem Belkov on 04.07.2026.
//

import SwiftNothingEar
import SwiftUI

struct DeviceModelSelection: Identifiable, Equatable {

    let id: String
    let model: DeviceModel
    let colorName: String
    let deviceImage: DeviceModel.DeviceImage

    var displayName: String {
        model.displayName
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.model == rhs.model &&
            lhs.colorName == rhs.colorName
    }

    static var all: [Self] {
        DeviceModelCatalog.all
    }

    static func selection(for id: String) -> Self? {
        DeviceModelCatalog.selection(for: id)
    }

    static func selection(for model: DeviceModel) -> Self? {
        DeviceModelCatalog.selection(for: model)
    }
}

struct DeviceSetupContext: Equatable {

    let identity: String
    let detectedModel: DeviceModel
    let mode: DeviceSetupMode
}

enum DeviceSetupMode: Equatable {
    case newDevice
    case editSelection
}

enum DeviceModelCatalog {

    static let all: [DeviceModelSelection] = [
        .init(id: "ear1.black", model: .ear1(.black), colorName: "Black", deviceImage: .buds(left: .ear1BlackLeft, right: .ear1BlackRight)),
        .init(id: "ear1.white", model: .ear1(.white), colorName: "White", deviceImage: .buds(left: .ear1WhiteLeft, right: .ear1WhiteRight)),
        .init(id: "ear2.black", model: .ear2(.black), colorName: "Black", deviceImage: .buds(left: .ear2BlackLeft, right: .ear2BlackRight)),
        .init(id: "ear2.white", model: .ear2(.white), colorName: "White", deviceImage: .buds(left: .ear2WhiteLeft, right: .ear2WhiteRight)),
        .init(id: "ear3.black", model: .ear3(.black), colorName: "Black", deviceImage: .buds(left: .ear3BlackLeft, right: .ear3BlackRight)),
        .init(id: "ear3.white", model: .ear3(.white), colorName: "White", deviceImage: .buds(left: .ear3WhiteLeft, right: .ear3WhiteRight)),
        .init(id: "earStick", model: .earStick, colorName: "White", deviceImage: .buds(left: .earStickLeft, right: .earStickRight)),
        .init(id: "earOpen.white", model: .earOpen(.white), colorName: "White", deviceImage: .buds(left: .earOpenWhiteLeft, right: .earOpenWhiteRight)),
        .init(id: "earOpen.blue", model: .earOpen(.blue), colorName: "Blue", deviceImage: .buds(left: .earOpenBlueLeft, right: .earOpenBlueRight)),
        .init(id: "ear.black", model: .ear(.black), colorName: "Black", deviceImage: .buds(left: .earBlackLeft, right: .earBlackRight)),
        .init(id: "ear.white", model: .ear(.white), colorName: "White", deviceImage: .buds(left: .earWhiteLeft, right: .earWhiteRight)),
        .init(id: "earA.black", model: .earA(.black), colorName: "Black", deviceImage: .buds(left: .earABlackLeft, right: .earABlackRight)),
        .init(id: "earA.white", model: .earA(.white), colorName: "White", deviceImage: .buds(left: .earAWhiteLeft, right: .earAWhiteRight)),
        .init(id: "earA.yellow", model: .earA(.yellow), colorName: "Yellow", deviceImage: .buds(left: .earAYellowLeft, right: .earAYellowRight)),
        .init(id: "headphone1.black", model: .headphone1(.black), colorName: "Black", deviceImage: .single(.headphone1Black)),
        .init(id: "headphone1.grey", model: .headphone1(.grey), colorName: "Grey", deviceImage: .single(.headphone1Grey)),
        .init(id: "headphoneA.black", model: .headphoneA(.black), colorName: "Black", deviceImage: .single(.headphoneABlack)),
        .init(id: "headphoneA.white", model: .headphoneA(.white), colorName: "White", deviceImage: .single(.headphoneAWhite)),
        .init(id: "headphoneA.yellow", model: .headphoneA(.yellow), colorName: "Yellow", deviceImage: .single(.headphoneAYellow)),
        .init(id: "headphoneA.pink", model: .headphoneA(.pink), colorName: "Pink", deviceImage: .single(.headphoneAPink)),
        .init(id: "cmfBudsPro.black", model: .cmfBudsPro(.black), colorName: "Black", deviceImage: .buds(left: .cmfBudsProBlackLeft, right: .cmfBudsProBlackRight)),
        .init(id: "cmfBudsPro.orange", model: .cmfBudsPro(.orange), colorName: "Orange", deviceImage: .buds(left: .cmfBudsProOrangeLeft, right: .cmfBudsProOrangeRight)),
        .init(id: "cmfBudsPro.white", model: .cmfBudsPro(.white), colorName: "White", deviceImage: .buds(left: .cmfBudsProWhiteLeft, right: .cmfBudsProWhiteRight)),
        .init(id: "cmfBuds.black", model: .cmfBuds(.black), colorName: "Black", deviceImage: .buds(left: .cmfBudsBlackLeft, right: .cmfBudsBlackRight)),
        .init(id: "cmfBuds.orange", model: .cmfBuds(.orange), colorName: "Orange", deviceImage: .buds(left: .cmfBudsOrangeLeft, right: .cmfBudsOrangeRight)),
        .init(id: "cmfBuds.white", model: .cmfBuds(.white), colorName: "White", deviceImage: .buds(left: .cmfBudsWhiteLeft, right: .cmfBudsWhiteRight)),
        .init(id: "cmfBuds2.lightGreen", model: .cmfBuds2(.lightGreen), colorName: "Light Green", deviceImage: .buds(left: .cmfBuds2GreenLeft, right: .cmfBuds2GreenRight)),
        .init(id: "cmfBuds2.orange", model: .cmfBuds2(.orange), colorName: "Orange", deviceImage: .buds(left: .cmfBuds2OrangeLeft, right: .cmfBuds2OrangeRight)),
        .init(id: "cmfBuds2.darkGrey", model: .cmfBuds2(.darkGrey), colorName: "Dark Grey", deviceImage: .buds(left: .cmfBuds2BlackLeft, right: .cmfBuds2BlackRight)),
        .init(id: "cmfBuds2a.lightGrey", model: .cmfBuds2a(.lightGrey), colorName: "Light Grey", deviceImage: .buds(left: .cmfBuds2ALightGreyLeft, right: .cmfBuds2ALightGreyRight)),
        .init(id: "cmfBuds2a.orange", model: .cmfBuds2a(.orange), colorName: "Orange", deviceImage: .buds(left: .cmfBuds2AOrangeLeft, right: .cmfBuds2AOrangeRight)),
        .init(id: "cmfBuds2a.darkGrey", model: .cmfBuds2a(.darkGrey), colorName: "Dark Grey", deviceImage: .buds(left: .cmfBuds2ABlackLeft, right: .cmfBuds2ABlackRight)),
        .init(id: "cmfBuds2Plus.blue", model: .cmfBuds2Plus(.blue), colorName: "Blue", deviceImage: .buds(left: .cmfBuds2PlusBlueLeft, right: .cmfBuds2PlusBlueRight)),
        .init(id: "cmfBuds2Plus.lightGrey", model: .cmfBuds2Plus(.lightGrey), colorName: "Light Grey", deviceImage: .buds(left: .cmfBuds2PlusLightGreyLeft, right: .cmfBuds2PlusLightGreyRight)),
        .init(id: "cmfBudsPro2.black", model: .cmfBudsPro2(.black), colorName: "Black", deviceImage: .buds(left: .cmfBudsPro2BlackLeft, right: .cmfBudsPro2BlackRight)),
        .init(id: "cmfBudsPro2.blue", model: .cmfBudsPro2(.blue), colorName: "Blue", deviceImage: .buds(left: .cmfBudsPro2BlueLeft, right: .cmfBudsPro2BlueRight)),
        .init(id: "cmfBudsPro2.orange", model: .cmfBudsPro2(.orange), colorName: "Orange", deviceImage: .buds(left: .cmfBudsPro2OrangeLeft, right: .cmfBudsPro2OrangeRight)),
        .init(id: "cmfBudsPro2.white", model: .cmfBudsPro2(.white), colorName: "White", deviceImage: .buds(left: .cmfBudsPro2WhiteLeft, right: .cmfBudsPro2WhiteRight)),
        .init(id: "cmfNeckbandPro.black", model: .cmfNeckbandPro(.black), colorName: "Black", deviceImage: .single(.cmfNeckbandProBlack)),
        .init(id: "cmfNeckbandPro.orange", model: .cmfNeckbandPro(.orange), colorName: "Orange", deviceImage: .single(.cmfNeckbandProOrange)),
        .init(id: "cmfNeckbandPro.white", model: .cmfNeckbandPro(.white), colorName: "White", deviceImage: .single(.cmfNeckbandProWhite)),
        .init(id: "cmfHeadphonePro.darkGrey", model: .cmfHeadphonePro(.darkGrey), colorName: "Dark Grey", deviceImage: .single(.cmfHeadphonePro1DarkGrey)),
        .init(id: "cmfHeadphonePro.lightGreen", model: .cmfHeadphonePro(.lightGreen), colorName: "Light Green", deviceImage: .single(.cmfHeadphonePro1LightGreen)),
        .init(id: "cmfHeadphonePro.lightGrey", model: .cmfHeadphonePro(.lightGrey), colorName: "Light Grey", deviceImage: .single(.cmfHeadphonePro1LightGrey))
    ]

    static func selection(for id: String) -> DeviceModelSelection? {
        all.first { $0.id == id }
    }

    static func selection(for model: DeviceModel) -> DeviceModelSelection? {
        all.first { $0.model == model }
    }
}
