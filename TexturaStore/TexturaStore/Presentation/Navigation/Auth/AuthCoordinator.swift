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
    
    private let authScreenFactory: AuthScreenBuilding
    private let privacyPolicyScreenFactory: PrivacyPolicyScreenBuilding
    
    // MARK: - Init
    
    init(
        authScreenFactory: AuthScreenBuilding,
        privacyPolicyScreenFactory: PrivacyPolicyScreenBuilding
    ) {
        self.authScreenFactory = authScreenFactory
        self.privacyPolicyScreenFactory = privacyPolicyScreenFactory
    }
    
    // MARK: - Coordinator Lifecycle
    
    func start() { }
    
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
                    // сюда позже добавишь route для reset password
                    _ = self
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
        }
    }
}
