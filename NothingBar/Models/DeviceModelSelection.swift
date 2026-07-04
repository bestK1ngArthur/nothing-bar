//
//  DeviceModelSelection.swift
//  NothingBar
//
//  Created by Artem Belkov on 04.07.2026.
//

import SwiftNothingEar

struct DeviceModelSelection: Identifiable, Equatable {

    let id: String
    let model: DeviceModel
    let colorName: String

    var displayName: String {
        model.displayName
    }

    static let all: [Self] = [
        .init(id: "ear1.black", model: .ear1(.black), colorName: "Black"),
        .init(id: "ear1.white", model: .ear1(.white), colorName: "White"),
        .init(id: "ear2.black", model: .ear2(.black), colorName: "Black"),
        .init(id: "ear2.white", model: .ear2(.white), colorName: "White"),
        .init(id: "ear3.black", model: .ear3(.black), colorName: "Black"),
        .init(id: "ear3.white", model: .ear3(.white), colorName: "White"),
        .init(id: "earStick", model: .earStick, colorName: "White"),
        .init(id: "earOpen.white", model: .earOpen(.white), colorName: "White"),
        .init(id: "earOpen.blue", model: .earOpen(.blue), colorName: "Blue"),
        .init(id: "ear.black", model: .ear(.black), colorName: "Black"),
        .init(id: "ear.white", model: .ear(.white), colorName: "White"),
        .init(id: "earA.black", model: .earA(.black), colorName: "Black"),
        .init(id: "earA.white", model: .earA(.white), colorName: "White"),
        .init(id: "earA.yellow", model: .earA(.yellow), colorName: "Yellow"),
        .init(id: "headphone1.black", model: .headphone1(.black), colorName: "Black"),
        .init(id: "headphone1.grey", model: .headphone1(.grey), colorName: "Grey"),
        .init(id: "headphoneA.black", model: .headphoneA(.black), colorName: "Black"),
        .init(id: "headphoneA.white", model: .headphoneA(.white), colorName: "White"),
        .init(id: "headphoneA.yellow", model: .headphoneA(.yellow), colorName: "Yellow"),
        .init(id: "headphoneA.pink", model: .headphoneA(.pink), colorName: "Pink"),
        .init(id: "cmfBudsPro.black", model: .cmfBudsPro(.black), colorName: "Black"),
        .init(id: "cmfBudsPro.orange", model: .cmfBudsPro(.orange), colorName: "Orange"),
        .init(id: "cmfBudsPro.white", model: .cmfBudsPro(.white), colorName: "White"),
        .init(id: "cmfBuds.black", model: .cmfBuds(.black), colorName: "Black"),
        .init(id: "cmfBuds.orange", model: .cmfBuds(.orange), colorName: "Orange"),
        .init(id: "cmfBuds.white", model: .cmfBuds(.white), colorName: "White"),
        .init(id: "cmfBuds2.lightGreen", model: .cmfBuds2(.lightGreen), colorName: "Light Green"),
        .init(id: "cmfBuds2.orange", model: .cmfBuds2(.orange), colorName: "Orange"),
        .init(id: "cmfBuds2.darkGrey", model: .cmfBuds2(.darkGrey), colorName: "Dark Grey"),
        .init(id: "cmfBuds2a.lightGrey", model: .cmfBuds2a(.lightGrey), colorName: "Light Grey"),
        .init(id: "cmfBuds2a.orange", model: .cmfBuds2a(.orange), colorName: "Orange"),
        .init(id: "cmfBuds2a.darkGrey", model: .cmfBuds2a(.darkGrey), colorName: "Dark Grey"),
        .init(id: "cmfBuds2Plus.blue", model: .cmfBuds2Plus(.blue), colorName: "Blue"),
        .init(id: "cmfBuds2Plus.lightGrey", model: .cmfBuds2Plus(.lightGrey), colorName: "Light Grey"),
        .init(id: "cmfBudsPro2.black", model: .cmfBudsPro2(.black), colorName: "Black"),
        .init(id: "cmfBudsPro2.blue", model: .cmfBudsPro2(.blue), colorName: "Blue"),
        .init(id: "cmfBudsPro2.orange", model: .cmfBudsPro2(.orange), colorName: "Orange"),
        .init(id: "cmfBudsPro2.white", model: .cmfBudsPro2(.white), colorName: "White"),
        .init(id: "cmfNeckbandPro.black", model: .cmfNeckbandPro(.black), colorName: "Black"),
        .init(id: "cmfNeckbandPro.orange", model: .cmfNeckbandPro(.orange), colorName: "Orange"),
        .init(id: "cmfNeckbandPro.white", model: .cmfNeckbandPro(.white), colorName: "White"),
        .init(id: "cmfHeadphonePro.darkGrey", model: .cmfHeadphonePro(.darkGrey), colorName: "Dark Grey"),
        .init(id: "cmfHeadphonePro.lightGreen", model: .cmfHeadphonePro(.lightGreen), colorName: "Light Green"),
        .init(id: "cmfHeadphonePro.lightGrey", model: .cmfHeadphonePro(.lightGrey), colorName: "Light Grey")
    ]

    static func selection(for id: String) -> Self? {
        all.first { $0.id == id }
    }

    static func selection(for model: DeviceModel) -> Self? {
        all.first { $0.model == model }
    }
}

struct DeviceSetupContext: Equatable {

    let identity: String
    let detectedModel: DeviceModel
}
