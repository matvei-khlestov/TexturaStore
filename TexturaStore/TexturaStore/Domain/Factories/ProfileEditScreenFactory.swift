//
//  ProfileEditScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import SwiftUI

@MainActor
final class ProfileEditScreenFactory: ProfileEditScreenBuilding {
    
    func makeEditProfileView(
        viewModel: any EditProfileViewModelProtocol,
        onEditName: (() -> Void)?,
        onEditEmail: (() -> Void)?,
        onEditPhone: (() -> Void)?,
        onBack: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            EditProfileView(
                viewModel: viewModel,
                onEditName: onEditName,
                onEditEmail: onEditEmail,
                onEditPhone: onEditPhone,
                onBack: onBack
            )
        )
    }
}
