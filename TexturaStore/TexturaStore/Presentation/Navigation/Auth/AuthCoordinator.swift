//
//  AuthCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class AuthCoordinator: AuthCoordinating {

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - Callbacks

    var onAuthSuccess: (() -> Void)?

    // MARK: - Dependencies

    private let screenFactory: AuthScreenBuilding

    // MARK: - Init

    init(screenFactory: AuthScreenBuilding) {
        self.screenFactory = screenFactory
    }

    // MARK: - Coordinator Lifecycle

    func start() { }

    func finish() {
        removeAllChildren()
    }

    // MARK: - Root View

    var rootView: AnyView {
        AnyView(
            AppNavigationContainer {
                screenFactory.makeAuthRootView(
                    start: .signIn,
                    onOpenPrivacy: { [weak self] in
                        // сюда позже заведёшь переход на экран/вебвью политики
                        _ = self
                    },
                    onForgotPassword: { [weak self] in
                        // сюда позже заведёшь переход на восстановление пароля
                        _ = self
                    }
                )
            }
        )
    }
}
