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
    
    var onLogout:        (() -> Void)?
    var onDeleteAccount: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let profileScreenFactory: any ProfileScreenBuilding
    private let privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding
    private let authService: AuthServiceProtocol
    private let makeProfileViewModel: (String) -> any ProfileUserViewModelProtocol
    private let makeOrdersViewModel: (String) -> OrdersViewModelProtocol
    private let languageProvider: any LanguageProviding
    private let settingsViewModel: any SettingsViewModelProtocol
    
    private let editProfileNavigator: any EditProfileNavigating
    
    // MARK: - Init
    
    init(
        profileScreenFactory: any ProfileScreenBuilding,
        privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding,
        authService: AuthServiceProtocol,
        makeProfileViewModel: @escaping (String) -> any ProfileUserViewModelProtocol,
        makeOrdersViewModel: @escaping (String) -> OrdersViewModelProtocol,
        languageProvider: any LanguageProviding,
        settingsViewModel: any SettingsViewModelProtocol,
        editProfileNavigator: any EditProfileNavigating
    ) {
        self.profileScreenFactory = profileScreenFactory
        self.privacyPolicyScreenFactory = privacyPolicyScreenFactory
        self.authService = authService
        self.makeProfileViewModel = makeProfileViewModel
        self.makeOrdersViewModel = makeOrdersViewModel
        self.languageProvider = languageProvider
        self.settingsViewModel = settingsViewModel
        self.editProfileNavigator = editProfileNavigator
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
            onEditProfileTap: { [weak self] in
                self?.router.push(.edit(.root))
            },
            onOrdersTap: { [weak self] in
                self?.router.push(.orders)
            },
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
            onLogoutTap: { [weak self] in
                self?.onLogout?()
            },
            onDeleteAccountTap: { [weak self] in
                self?.onDeleteAccount?()
            }
        )
    }
    
    func buildStack(_ route: ProfileRoute) -> AnyView {
        switch route {
            
        case .root:
            return makeRoot()
            
        case .orders:
            let userId = authService.currentUserId ?? ""
            let ordersViewModel = makeOrdersViewModel(userId)
            
            return profileScreenFactory.makeOrdersView(
                viewModel: ordersViewModel,
                languageProvider: languageProvider,
                localizer: nil,
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )
            
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
            
        case .edit(let editRoute):
            return buildEditRoute(editRoute)
        }
    }
    
    // MARK: - Private
    
    private func buildEditRoute(_ editRoute: EditProfileRoute) -> AnyView {
        switch editRoute {
            
        case .root:
            return editProfileNavigator.makeRoot(
                onEditName: { [weak self] in
                    self?.router.push(.edit(.editName))
                },
                onEditEmail: { [weak self] in
                    self?.router.push(.edit(.editEmail))
                },
                onEditPhone: { [weak self] in
                    self?.router.push(.edit(.editPhone))
                },
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )
            
        case .editName:
            return editProfileNavigator.makeDestination(
                route: .editName,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onFinish: { [weak self] in
                    self?.router.pop()
                }
            )
            
        case .editEmail:
            return editProfileNavigator.makeDestination(
                route: .editEmail,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onFinish: { [weak self] in
                    self?.router.pop()
                }
            )
            
        case .editPhone:
            return editProfileNavigator.makeDestination(
                route: .editPhone,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onFinish: { [weak self] in
                    self?.router.pop()
                }
            )
        }
    }
}
