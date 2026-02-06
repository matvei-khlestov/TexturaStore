//
//  ProfileScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import SwiftUI

@MainActor
protocol ProfileScreenBuilding {
    func makeProfileRootView(
        viewModel: any ProfileViewModelProtocol,
        onLogout: @escaping () -> Void
    ) -> AnyView
}
