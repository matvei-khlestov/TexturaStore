//
//  AuthCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class AuthCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - Callbacks

    var onAuthSuccess: (() -> Void)?

    // MARK: - Coordinator Lifecycle

    func start() {
        // Позже: сброс внутренних auth-route'ов (login/register/reset)
    }

    func finish() {
        removeAllChildren()
    }

    // MARK: - Root View

    var rootView: some View {
        AppNavigationContainer {
            AuthRootView(
                onAuthSuccess: { [weak self] in
                    self?.onAuthSuccess?()
                }
            )
        }
    }
}
