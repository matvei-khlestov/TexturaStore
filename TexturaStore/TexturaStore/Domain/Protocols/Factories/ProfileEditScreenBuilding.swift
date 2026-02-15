//
//  ProfileEditScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import SwiftUI

@MainActor
protocol ProfileEditScreenBuilding {
    func makeEditProfileView(
        viewModel: any EditProfileViewModelProtocol,
        onEditName: (() -> Void)?,
        onEditEmail: (() -> Void)?,
        onEditPhone: (() -> Void)?,
        onBack: @escaping () -> Void
    ) -> AnyView
    
    func makeEditNameView(
        viewModel: any EditNameViewModelProtocol,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView
    
    func makeEditEmailView(
        viewModel: any EditEmailViewModelProtocol,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView
    
    func makeEditPhoneView(
        viewModel: any EditPhoneViewModelProtocol,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView
}
