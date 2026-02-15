//
//  EditProfileNavigator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import SwiftUI

@MainActor
final class EditProfileNavigator: EditProfileNavigating {
    
    // MARK: - Deps
    
    private let profileEditScreenFactory: any ProfileEditScreenBuilding
    private let authService: AuthServiceProtocol
    private let makeEditProfileViewModel: (String) -> any EditProfileViewModelProtocol
    private let makeEditNameViewModel: (String) -> any EditNameViewModelProtocol
    private let makeEditEmailViewModel: (String) -> any EditEmailViewModelProtocol
    
    // MARK: - Init
    
    init(
        profileEditScreenFactory: any ProfileEditScreenBuilding,
        authService: AuthServiceProtocol,
        makeEditProfileViewModel: @escaping (String) -> any EditProfileViewModelProtocol,
        makeEditNameViewModel: @escaping (String) -> any EditNameViewModelProtocol,
        makeEditEmailViewModel: @escaping (String) -> any EditEmailViewModelProtocol
    ) {
        self.profileEditScreenFactory = profileEditScreenFactory
        self.authService = authService
        self.makeEditProfileViewModel = makeEditProfileViewModel
        self.makeEditNameViewModel = makeEditNameViewModel
        self.makeEditEmailViewModel = makeEditEmailViewModel
    }
    
    // MARK: - Screens
    
    func makeRoot(
        onEditName: @escaping () -> Void,
        onEditEmail: @escaping () -> Void,
        onEditPhone: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) -> AnyView {
        let userId = authService.currentUserId ?? ""
        let vm = makeEditProfileViewModel(userId)
        
        return profileEditScreenFactory.makeEditProfileView(
            viewModel: vm,
            onEditName: onEditName,
            onEditEmail: onEditEmail,
            onEditPhone: onEditPhone,
            onBack: onBack
        )
    }
    
    func makeDestination(
        route: EditProfileRoute,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView {
        switch route {
        case .root:
            return makeRoot(
                onEditName: {},
                onEditEmail: {},
                onEditPhone: {},
                onBack: onBack
            )
            
        case .editName:
            let userId = authService.currentUserId ?? ""
            let vm = makeEditNameViewModel(userId)
            
            return profileEditScreenFactory.makeEditNameView(
                viewModel: vm,
                onBack: onBack,
                onFinish: onFinish
            )
            
        case .editEmail:
            let userId = authService.currentUserId ?? ""
            let vm = makeEditEmailViewModel(userId)
            
            return profileEditScreenFactory.makeEditEmailView(
                viewModel: vm,
                onBack: onBack,
                onFinish: onFinish
            )
        }
    }
}
