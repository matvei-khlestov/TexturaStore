//
//  ProfileEditCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class ProfileEditCoordinator: ProfileEditCoordinating, @MainActor RoutableCoordinator {
    
    // MARK: - Routes
    
    typealias StackRoute = ProfileEditRoute
    
    // MARK: - Coordinator
    
    var childCoordinators: [any CoordinatorBox] = []
    
    // MARK: - Router
    
    let router: AppRouter<ProfileEditRoute, NoRoute, NoRoute> = AppRouter()
    
    // MARK: - Callbacks
    
    var onEditName:  (() -> Void)?
    var onEditEmail: (() -> Void)?
    var onEditPhone: (() -> Void)?
    var onFinish:    (() -> Void)?
    
    // MARK: - Dependencies
    
    private let profileEditScreenFactory: any ProfileEditScreenBuilding
    private let authService: AuthServiceProtocol
    private let makeEditProfileViewModel: (String) -> any EditProfileViewModelProtocol
    
    // MARK: - Init
    
    init(
        profileEditScreenFactory: any ProfileEditScreenBuilding,
        authService: AuthServiceProtocol,
        makeEditProfileViewModel: @escaping (String) -> any EditProfileViewModelProtocol
    ) {
        self.profileEditScreenFactory = profileEditScreenFactory
        self.authService = authService
        self.makeEditProfileViewModel = makeEditProfileViewModel
    }
    
    // MARK: - Coordinator Lifecycle
    
    func start() {
        router.resetAll()
    }
    
    func finish() {
        router.resetAll()
        removeAllChildren()
    }
    
    // MARK: - RoutableCoordinator
    
    func makeRoot() -> AnyView {
        let userId = authService.currentUserId ?? ""
        let viewModel = makeEditProfileViewModel(userId)
        
        return profileEditScreenFactory.makeEditProfileView(
            viewModel: viewModel,
            onEditName: { [weak self] in self?.onEditName?() },
            onEditEmail: { [weak self] in self?.onEditEmail?() },
            onEditPhone: { [weak self] in self?.onEditPhone?() },
            onBack: { [weak self] in
                self?.onFinish?()
            }
        )
    }
    
    func buildStack(_ route: ProfileEditRoute) -> AnyView {
        switch route {
        case .root:
            return makeRoot()
        }
    }
}
