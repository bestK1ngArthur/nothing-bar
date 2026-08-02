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
    /// Stable, untranslated color identifier — used for matching (e.g. swatch color lookup). Use `colorName` for display.
    let colorKey: String
    let deviceImage: DeviceModel.DeviceImage

    var displayName: String {
        model.displayName
    }

    var colorName: String {
        switch colorKey {
            case "Black":
                String(localized: "Black", comment: "Device color name")
            case "White":
                String(localized: "White", comment: "Device color name")
            case "Yellow":
                String(localized: "Yellow", comment: "Device color name")
            case "Pink":
                String(localized: "Pink", comment: "Device color name")
            case "Blue":
                String(localized: "Blue", comment: "Device color name")
            case "Grey":
                String(localized: "Grey", comment: "Device color name")
            case "Orange":
                String(localized: "Orange", comment: "Device color name")
            case "Light Green":
                String(localized: "Light Green", comment: "Device color name")
            case "Dark Grey":
                String(localized: "Dark Grey", comment: "Device color name")
            case "Light Grey":
                String(localized: "Light Grey", comment: "Device color name")
            default:
                colorKey
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.model == rhs.model &&
            lhs.colorKey == rhs.colorKey
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
        .init(id: "ear1.black", model: .ear1(.black), colorKey: "Black", deviceImage: .buds(left: .ear1BlackLeft, right: .ear1BlackRight)),
        .init(id: "ear1.white", model: .ear1(.white), colorKey: "White", deviceImage: .buds(left: .ear1WhiteLeft, right: .ear1WhiteRight)),
        .init(id: "ear2.black", model: .ear2(.black), colorKey: "Black", deviceImage: .buds(left: .ear2BlackLeft, right: .ear2BlackRight)),
        .init(id: "ear2.white", model: .ear2(.white), colorKey: "White", deviceImage: .buds(left: .ear2WhiteLeft, right: .ear2WhiteRight)),
        .init(id: "ear3.black", model: .ear3(.black), colorKey: "Black", deviceImage: .buds(left: .ear3BlackLeft, right: .ear3BlackRight)),
        .init(id: "ear3.white", model: .ear3(.white), colorKey: "White", deviceImage: .buds(left: .ear3WhiteLeft, right: .ear3WhiteRight)),
        .init(id: "ear3A.black", model: .ear3A(.black), colorKey: "Black", deviceImage: .buds(left: .ear3ABlackLeft, right: .ear3ABlackRight)),
        .init(id: "ear3A.white", model: .ear3A(.white), colorKey: "White", deviceImage: .buds(left: .ear3AWhiteLeft, right: .ear3AWhiteRight)),
        .init(id: "ear3A.yellow", model: .ear3A(.yellow), colorKey: "Yellow", deviceImage: .buds(left: .ear3AYellowLeft, right: .ear3AYellowRight)),
        .init(id: "ear3A.pink", model: .ear3A(.pink), colorKey: "Pink", deviceImage: .buds(left: .ear3APinkLeft, right: .ear3APinkRight)),
        .init(id: "earStick", model: .earStick, colorKey: "White", deviceImage: .buds(left: .earStickLeft, right: .earStickRight)),
        .init(id: "earOpen.white", model: .earOpen(.white), colorKey: "White", deviceImage: .buds(left: .earOpenWhiteLeft, right: .earOpenWhiteRight)),
        .init(id: "earOpen.blue", model: .earOpen(.blue), colorKey: "Blue", deviceImage: .buds(left: .earOpenBlueLeft, right: .earOpenBlueRight)),
        .init(id: "ear.black", model: .ear(.black), colorKey: "Black", deviceImage: .buds(left: .earBlackLeft, right: .earBlackRight)),
        .init(id: "ear.white", model: .ear(.white), colorKey: "White", deviceImage: .buds(left: .earWhiteLeft, right: .earWhiteRight)),
        .init(id: "earA.black", model: .earA(.black), colorKey: "Black", deviceImage: .buds(left: .earABlackLeft, right: .earABlackRight)),
        .init(id: "earA.white", model: .earA(.white), colorKey: "White", deviceImage: .buds(left: .earAWhiteLeft, right: .earAWhiteRight)),
        .init(id: "earA.yellow", model: .earA(.yellow), colorKey: "Yellow", deviceImage: .buds(left: .earAYellowLeft, right: .earAYellowRight)),
        .init(id: "headphone1.black", model: .headphone1(.black), colorKey: "Black", deviceImage: .single(.headphone1Black)),
        .init(id: "headphone1.grey", model: .headphone1(.grey), colorKey: "Grey", deviceImage: .single(.headphone1Grey)),
        .init(id: "headphoneA.black", model: .headphoneA(.black), colorKey: "Black", deviceImage: .single(.headphoneABlack)),
        .init(id: "headphoneA.white", model: .headphoneA(.white), colorKey: "White", deviceImage: .single(.headphoneAWhite)),
        .init(id: "headphoneA.yellow", model: .headphoneA(.yellow), colorKey: "Yellow", deviceImage: .single(.headphoneAYellow)),
        .init(id: "headphoneA.pink", model: .headphoneA(.pink), colorKey: "Pink", deviceImage: .single(.headphoneAPink)),
        .init(id: "cmfBudsPro.black", model: .cmfBudsPro(.black), colorKey: "Black", deviceImage: .buds(left: .cmfBudsProBlackLeft, right: .cmfBudsProBlackRight)),
        .init(id: "cmfBudsPro.orange", model: .cmfBudsPro(.orange), colorKey: "Orange", deviceImage: .buds(left: .cmfBudsProOrangeLeft, right: .cmfBudsProOrangeRight)),
        .init(id: "cmfBudsPro.white", model: .cmfBudsPro(.white), colorKey: "White", deviceImage: .buds(left: .cmfBudsProWhiteLeft, right: .cmfBudsProWhiteRight)),
        .init(id: "cmfBuds.black", model: .cmfBuds(.black), colorKey: "Black", deviceImage: .buds(left: .cmfBudsBlackLeft, right: .cmfBudsBlackRight)),
        .init(id: "cmfBuds.orange", model: .cmfBuds(.orange), colorKey: "Orange", deviceImage: .buds(left: .cmfBudsOrangeLeft, right: .cmfBudsOrangeRight)),
        .init(id: "cmfBuds.white", model: .cmfBuds(.white), colorKey: "White", deviceImage: .buds(left: .cmfBudsWhiteLeft, right: .cmfBudsWhiteRight)),
        .init(id: "cmfBuds2.lightGreen", model: .cmfBuds2(.lightGreen), colorKey: "Light Green", deviceImage: .buds(left: .cmfBuds2GreenLeft, right: .cmfBuds2GreenRight)),
        .init(id: "cmfBuds2.orange", model: .cmfBuds2(.orange), colorKey: "Orange", deviceImage: .buds(left: .cmfBuds2OrangeLeft, right: .cmfBuds2OrangeRight)),
        .init(id: "cmfBuds2.darkGrey", model: .cmfBuds2(.darkGrey), colorKey: "Dark Grey", deviceImage: .buds(left: .cmfBuds2BlackLeft, right: .cmfBuds2BlackRight)),
        .init(id: "cmfBuds2a.lightGrey", model: .cmfBuds2a(.lightGrey), colorKey: "Light Grey", deviceImage: .buds(left: .cmfBuds2ALightGreyLeft, right: .cmfBuds2ALightGreyRight)),
        .init(id: "cmfBuds2a.orange", model: .cmfBuds2a(.orange), colorKey: "Orange", deviceImage: .buds(left: .cmfBuds2AOrangeLeft, right: .cmfBuds2AOrangeRight)),
        .init(id: "cmfBuds2a.darkGrey", model: .cmfBuds2a(.darkGrey), colorKey: "Dark Grey", deviceImage: .buds(left: .cmfBuds2ABlackLeft, right: .cmfBuds2ABlackRight)),
        .init(id: "cmfBuds2Plus.blue", model: .cmfBuds2Plus(.blue), colorKey: "Blue", deviceImage: .buds(left: .cmfBuds2PlusBlueLeft, right: .cmfBuds2PlusBlueRight)),
        .init(id: "cmfBuds2Plus.lightGrey", model: .cmfBuds2Plus(.lightGrey), colorKey: "Light Grey", deviceImage: .buds(left: .cmfBuds2PlusLightGreyLeft, right: .cmfBuds2PlusLightGreyRight)),
        .init(id: "cmfBudsPro2.black", model: .cmfBudsPro2(.black), colorKey: "Black", deviceImage: .buds(left: .cmfBudsPro2BlackLeft, right: .cmfBudsPro2BlackRight)),
        .init(id: "cmfBudsPro2.blue", model: .cmfBudsPro2(.blue), colorKey: "Blue", deviceImage: .buds(left: .cmfBudsPro2BlueLeft, right: .cmfBudsPro2BlueRight)),
        .init(id: "cmfBudsPro2.orange", model: .cmfBudsPro2(.orange), colorKey: "Orange", deviceImage: .buds(left: .cmfBudsPro2OrangeLeft, right: .cmfBudsPro2OrangeRight)),
        .init(id: "cmfBudsPro2.white", model: .cmfBudsPro2(.white), colorKey: "White", deviceImage: .buds(left: .cmfBudsPro2WhiteLeft, right: .cmfBudsPro2WhiteRight)),
        .init(id: "cmfNeckbandPro.black", model: .cmfNeckbandPro(.black), colorKey: "Black", deviceImage: .single(.cmfNeckbandProBlack)),
        .init(id: "cmfNeckbandPro.orange", model: .cmfNeckbandPro(.orange), colorKey: "Orange", deviceImage: .single(.cmfNeckbandProOrange)),
        .init(id: "cmfNeckbandPro.white", model: .cmfNeckbandPro(.white), colorKey: "White", deviceImage: .single(.cmfNeckbandProWhite)),
        .init(id: "cmfHeadphonePro.darkGrey", model: .cmfHeadphonePro(.darkGrey), colorKey: "Dark Grey", deviceImage: .single(.cmfHeadphonePro1DarkGrey)),
        .init(id: "cmfHeadphonePro.lightGreen", model: .cmfHeadphonePro(.lightGreen), colorKey: "Light Green", deviceImage: .single(.cmfHeadphonePro1LightGreen)),
        .init(id: "cmfHeadphonePro.lightGrey", model: .cmfHeadphonePro(.lightGrey), colorKey: "Light Grey", deviceImage: .single(.cmfHeadphonePro1LightGrey))
    ]

    static func selection(for id: String) -> DeviceModelSelection? {
        all.first { $0.id == id }
    }

    static func selection(for model: DeviceModel) -> DeviceModelSelection? {
        all.first { $0.model == model }
    }
}
