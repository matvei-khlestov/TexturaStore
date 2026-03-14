//
//  BootScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import SwiftUI

@MainActor
final class BootScreenFactory: BootScreenBuilding {

    func makeBootView() -> AnyView {
        AnyView(
            BootView()
        )
    }
}
