//
//  ProfileScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import SwiftUI

@MainActor
final class ProfileScreenFactory: ProfileScreenBuilding {
    
    func makeProfileRootView(
        viewModel: any ProfileViewModelProtocol,
        onLogout: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            ProfileRootView(
                viewModel: viewModel,
                onLogout: onLogout
            )
        )
    }
}
