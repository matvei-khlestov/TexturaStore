//
//  AuthCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class AuthCoordinator: AuthCoordinating, @MainActor RoutableCoordinator {

    // MARK: - Routes

    typealias StackRoute = AuthRoute

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - Router

    let router: AppRouter<AuthRoute, NoRoute, NoRoute> = AppRouter()

    // MARK: - Callbacks

    var onAuthSuccess: (() -> Void)?

    // MARK: - Dependencies

    private let authService: any AuthServiceProtocol
    private let authScreenFactory: any AuthScreenBuilding
    private let privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding
    private let resetPasswordViewModel: any ResetPasswordViewModelProtocol

    // MARK: - Init

    init(
        authService: any AuthServiceProtocol,
        authScreenFactory: any AuthScreenBuilding,
        privacyPolicyScreenFactory: any PrivacyPolicyScreenBuilding,
        resetPasswordViewModel: any ResetPasswordViewModelProtocol
    ) {
        self.authService = authService
        self.authScreenFactory = authScreenFactory
        self.privacyPolicyScreenFactory = privacyPolicyScreenFactory
        self.resetPasswordViewModel = resetPasswordViewModel
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
        AnyView(
            authScreenFactory.makeAuthRootView(
                start: .signIn,
                onOpenPrivacy: { [weak self] in
                    self?.router.push(.privacyPolicy)
                },
                onForgotPassword: { [weak self] in
                    self?.router.push(.resetPassword)
                }
            )
        )
    }

    func buildStack(_ route: AuthRoute) -> AnyView {
        switch route {
        case .privacyPolicy:
            return privacyPolicyScreenFactory.makePrivacyPolicyView(
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )

        case .resetPassword:
            return authScreenFactory.makeResetPasswordView(
                viewModel: resetPasswordViewModel,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onDone: { [weak self] in
                    self?.router.pop()
                }
            )
        }
    }
}
