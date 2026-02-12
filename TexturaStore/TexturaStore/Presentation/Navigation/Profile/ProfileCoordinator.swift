//
//  ProfileCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class ProfileCoordinator: ProfileCoordinating, @MainActor RoutableCoordinator {
    
    // MARK: - Routes
    
    typealias StackRoute = ProfileRoute
    
    // MARK: - Coordinator
    
    var childCoordinators: [any CoordinatorBox] = []
    
    // MARK: - Router
    
    let router: AppRouter<ProfileRoute, NoRoute, NoRoute> = AppRouter()
    
    // MARK: - Callbacks
    
    var onEditProfileTap:   (() -> Void)?
    var onOrdersTap:        (() -> Void)?
    var onSettingsTap:      (() -> Void)?
    var onAboutTap:         (() -> Void)?
    var onContactTap:       (() -> Void)?
    var onLogout:           (() -> Void)?
    var onDeleteAccount:    (() -> Void)?
    
    // MARK: - Dependencies
    
    private let profileScreenFactory: any ProfileScreenBuilding
    private let privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding
    private let authService: AuthServiceProtocol
    private let makeProfileViewModel: (String) -> any ProfileUserViewModelProtocol
    private let settingsViewModel: any SettingsViewModelProtocol
    
    // MARK: - Init
    
    init(
        profileScreenFactory: any ProfileScreenBuilding,
        privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding,
        authService: AuthServiceProtocol,
        makeProfileViewModel: @escaping (String) -> any ProfileUserViewModelProtocol,
        settingsViewModel: any SettingsViewModelProtocol
    ) {
        self.profileScreenFactory = profileScreenFactory
        self.privacyPolicyScreenFactory = privacyPolicyScreenFactory
        self.authService = authService
        self.makeProfileViewModel = makeProfileViewModel
        self.settingsViewModel = settingsViewModel
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
        let vm = makeProfileViewModel(userId)
        
        return profileScreenFactory.makeProfileUserView(
            viewModel: vm,
            onEditProfileTap: { [weak self] in self?.onEditProfileTap?() },
            onOrdersTap: { [weak self] in self?.onOrdersTap?() },
            
            onSettingsTap: { [weak self] in
                self?.router.push(.settings)
            },
            
            onAboutTap: { [weak self] in
                self?.router.push(.about)
            },
            
            onContactTap: { [weak self] in
                self?.router.push(.contactUs)
            },
            
            onPrivacyTap: { [weak self] in
                self?.router.push(.privacyPolicy)
            },
            
            onLogoutTap: { [weak self] in self?.onLogout?() },
            onDeleteAccountTap: { [weak self] in self?.onDeleteAccount?() }
        )
    }
    
    func buildStack(_ route: ProfileRoute) -> AnyView {
        switch route {
            
        case .privacyPolicy:
            return privacyPolicyScreenFactory.makePrivacyPolicyView(
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )
            
        case .contactUs:
            return profileScreenFactory.makeContactUsView(
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )
            
        case .about:
            return profileScreenFactory.makeAboutView(
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )
            
        case .settings:
            return profileScreenFactory.makeSettingsView(
                viewModel: settingsViewModel,
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )
        }
    }
}
