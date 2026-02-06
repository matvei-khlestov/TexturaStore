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

    private let authService: AuthServiceProtocol
    private let authScreenFactory: AuthScreenBuilding
    private let privacyPolicyScreenFactory: PrivacyPolicyScreenBuilding
    private let resetPasswordViewModel: ResetPasswordViewModelProtocol

    // MARK: - State

    private var bag = Set<AnyCancellable>()

    // MARK: - Init

    init(
        authService: AuthServiceProtocol,
        authScreenFactory: AuthScreenBuilding,
        privacyPolicyScreenFactory: PrivacyPolicyScreenBuilding,
        resetPasswordViewModel: ResetPasswordViewModelProtocol
    ) {
        self.authService = authService
        self.authScreenFactory = authScreenFactory
        self.privacyPolicyScreenFactory = privacyPolicyScreenFactory
        self.resetPasswordViewModel = resetPasswordViewModel
    }

    // MARK: - Coordinator Lifecycle

    func start() {}

    func finish() {
        bag.removeAll()
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
