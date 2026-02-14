//
//  ProfileCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI
import Combine

/// Координатор `ProfileCoordinator` управляет сценарием отображения профиля пользователя (SwiftUI).
///
/// Отвечает за:
/// - создание и показ `ProfileUserView` как root;
/// - навигацию к экранам: настройки/о нас/контакты/политика (через stack routes);
/// - переход в сценарий редактирования профиля push-ом в стек (ProfileRoute.editProfile);
/// - проброс наружу событий выхода и удаления аккаунта.
///
/// Особенности:
/// - использует `NavigationHost` + `AppRouter` (iOS 15 compatible);
/// - держит `ProfileEditCoordinator` как child, чтобы не терялся из памяти;
/// - изолирует навигацию от UI/VM (Coordinator).
@MainActor
final class ProfileCoordinator: ProfileCoordinating, @MainActor RoutableCoordinator {

    // MARK: - Routes

    typealias StackRoute = ProfileRoute

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - Router

    let router: AppRouter<ProfileRoute, NoRoute, NoRoute> = AppRouter()

    // MARK: - Callbacks

    var onOrdersTap:        (() -> Void)?
    var onLogout:           (() -> Void)?
    var onDeleteAccount:    (() -> Void)?

    // MARK: - Dependencies

    private let profileScreenFactory: any ProfileScreenBuilding
    private let privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding
    private let authService: AuthServiceProtocol
    private let makeProfileViewModel: (String) -> any ProfileUserViewModelProtocol
    private let settingsViewModel: any SettingsViewModelProtocol

    private let profileEditCoordinator: any ProfileEditCoordinating

    // MARK: - Init

    init(
        profileScreenFactory: any ProfileScreenBuilding,
        privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding,
        authService: AuthServiceProtocol,
        makeProfileViewModel: @escaping (String) -> any ProfileUserViewModelProtocol,
        settingsViewModel: any SettingsViewModelProtocol,
        profileEditCoordinator: any ProfileEditCoordinating
    ) {
        self.profileScreenFactory = profileScreenFactory
        self.privacyPolicyScreenFactory = privacyPolicyScreenFactory
        self.authService = authService
        self.makeProfileViewModel = makeProfileViewModel
        self.settingsViewModel = settingsViewModel
        self.profileEditCoordinator = profileEditCoordinator

        storeChild(profileEditCoordinator)
        bindProfileEdit()
    }

    // MARK: - Coordinator Lifecycle

    func start() {
        router.resetAll()
    }

    func finish() {
        router.resetAll()
        profileEditCoordinator.finish()
        removeAllChildren()
    }

    // MARK: - RoutableCoordinator

    func makeRoot() -> AnyView {
        let userId = authService.currentUserId ?? ""
        let vm = makeProfileViewModel(userId)

        return profileScreenFactory.makeProfileUserView(
            viewModel: vm,
            onEditProfileTap: { [weak self] in
                self?.profileEditCoordinator.start()
                self?.router.push(.editProfile)
            },
            onOrdersTap: { [weak self] in
                self?.onOrdersTap?()
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

        case .privacyPolicy:
            return privacyPolicyScreenFactory.makePrivacyPolicyView(
                onBack: { [weak self] in self?.router.pop() }
            )

        case .contactUs:
            return profileScreenFactory.makeContactUsView(
                onBack: { [weak self] in self?.router.pop() }
            )

        case .about:
            return profileScreenFactory.makeAboutView(
                onBack: { [weak self] in self?.router.pop() }
            )

        case .settings:
            return profileScreenFactory.makeSettingsView(
                viewModel: settingsViewModel,
                onBack: { [weak self] in self?.router.pop() }
            )

        case .editProfile:
            return profileEditCoordinator.makeRoot()
        }
    }

    // MARK: - Private

    private func bindProfileEdit() {
        profileEditCoordinator.onFinish = { [weak self] in
            self?.profileEditCoordinator.finish()
            self?.router.pop()
        }
    }
}
