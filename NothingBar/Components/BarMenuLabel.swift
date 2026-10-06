//
//  BarMenuLabel.swift
//  NothingBar
//
//  Created by Artem Belkov on 06.10.2026.
//

import SwiftUI

/// Value label for the compact menus in the bar. Pair with `.menuIndicator(.hidden)`:
/// the native indicator can't be tinted, so the label draws its own chevron in the value's color.
struct BarMenuLabel: View {

    let title: String

    var body: some View {
        (Text(title) + Text(" ") + Text(Image(systemName: "chevron.down")).font(.caption2.weight(.semibold)))
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}
