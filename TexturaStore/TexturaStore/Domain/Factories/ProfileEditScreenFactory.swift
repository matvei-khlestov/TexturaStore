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
    
    func makeEditNameView(
        viewModel: any EditNameViewModelProtocol,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            EditNameView(
                viewModel: viewModel,
                onBack: onBack,
                onFinish: onFinish
            )
        )
    }
    
    func makeEditEmailView(
        viewModel: any EditEmailViewModelProtocol,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            EditEmailView(
                viewModel: viewModel,
                onBack: onBack,
                onFinish: onFinish
            )
        )
    }
    
    func makeEditPhoneView(
        viewModel: any EditPhoneViewModelProtocol,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            EditPhoneView(
                viewModel: viewModel,
                onBack: onBack,
                onFinish: onFinish
            )
        )
    }
}
