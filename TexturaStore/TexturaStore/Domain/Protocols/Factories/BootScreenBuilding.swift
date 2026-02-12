//
//  BootScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import SwiftUI

@MainActor
protocol BootScreenBuilding {
    func makeBootView() -> AnyView
}
