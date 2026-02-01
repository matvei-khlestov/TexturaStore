//
//  AppCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class AppCoordinator: AppCoordinating, ObservableObject {

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - State

    @Published private(set) var route: AppRoute = .auth

    // MARK: - Dependencies

    private let authCoordinator: any AuthCoordinating
    private let mainTabCoordinator: any MainTabCoordinating

    // MARK: - Init

    init(
        authCoordinator: any AuthCoordinating,
        mainTabCoordinator: any MainTabCoordinating
    ) {
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

    var rootView: AnyView {
        AnyView(
            Group {
                switch route {
                case .auth:
                    authCoordinator.rootView
                case .main:
                    mainTabCoordinator.rootView
                }
            }
        )
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
