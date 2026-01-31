//
//  AppCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class AppCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - State

    @Published private(set) var route: AppRoute = .auth

    // MARK: - Dependencies

    private let authCoordinator: AuthCoordinator
    private let mainTabCoordinator: MainTabCoordinator

    // MARK: - Init

    init(authCoordinator: AuthCoordinator,
         mainTabCoordinator: MainTabCoordinator) {
        self.authCoordinator = authCoordinator
        self.mainTabCoordinator = mainTabCoordinator
        bind()
        storeChild(authCoordinator)
        storeChild(mainTabCoordinator)
    }

    // MARK: - Coordinator Lifecycle

    func start() {
        route = .auth
        authCoordinator.start()
        mainTabCoordinator.start()
    }

    func finish() {
        authCoordinator.finish()
        mainTabCoordinator.finish()
        removeAllChildren()
    }

    // MARK: - Root View

    var rootView: some View {
        Group {
            switch route {
            case .auth:
                authCoordinator.rootView
            case .main:
                mainTabCoordinator.rootView
            }
        }
    }

    // MARK: - Routing

    func showAuth() {
        mainTabCoordinator.finish()
        route = .auth
        authCoordinator.start()
    }

    func showMain() {
        authCoordinator.finish()
        route = .main
        mainTabCoordinator.start()
    }

    // MARK: - Private

    private func bind() {
        authCoordinator.onAuthSuccess = { [weak self] in
            self?.showMain()
        }

        mainTabCoordinator.onLogout = { [weak self] in
            self?.showAuth()
        }
    }
}
