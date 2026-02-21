//
//  BarNotificationView.swift
//  NothingBar
//
//  Created by Artem Belkov on 29.09.2025.
//

import SwiftUI

struct BarNotificationView: View {

    @Environment(AppData.self) var appData
    let style: NotificationStyle

    var body: some View {
        switch style {
            case .classic:
                BarNotificationClassicView()
                    .environment(appData)

            case .apple:
                BarNotificationAppleView()
                    .environment(appData)
        }
    }
}
