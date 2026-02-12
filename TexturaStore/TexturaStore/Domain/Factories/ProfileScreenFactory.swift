//
//  ProfileScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import SwiftUI

@MainActor
final class ProfileScreenFactory: ProfileScreenBuilding {
    
    func makeProfileUserView(
        viewModel: any ProfileUserViewModelProtocol,
        onEditProfileTap: (() -> Void)?,
        onOrdersTap: (() -> Void)?,
        onSettingsTap: (() -> Void)?,
        onAboutTap: (() -> Void)?,
        onContactTap: (() -> Void)?,
        onPrivacyTap: (() -> Void)?,
        onLogoutTap: @escaping () -> Void,
        onDeleteAccountTap: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            ProfileUserView(
                viewModel: viewModel,
                onEditProfileTap: onEditProfileTap,
                onOrdersTap: onOrdersTap,
                onSettingsTap: onSettingsTap,
                onAboutTap: onAboutTap,
                onContactTap: onContactTap,
                onPrivacyTap: onPrivacyTap,
                onLogoutTap: onLogoutTap,
                onDeleteAccountTap: onDeleteAccountTap
            )
        )
    }
}
