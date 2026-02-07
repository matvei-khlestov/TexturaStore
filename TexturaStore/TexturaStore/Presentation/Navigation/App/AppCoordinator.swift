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
    
    @Published private(set) var route: AppRoute
    
    // MARK: - Dependencies
    
    private let authCoordinator: any AuthCoordinating
    private let mainTabCoordinator: any MainTabCoordinating
    private let authService: any AuthServiceProtocol
    private let sessionStorage: any AuthSessionStoringProtocol
    
    // MARK: - Subscriptions
    
    private var bag = Set<AnyCancellable>()
    private var isStarted = false
    
    // MARK: - Init
    
    init(
        authCoordinator: any AuthCoordinating,
        mainTabCoordinator: any MainTabCoordinating,
        authService: any AuthServiceProtocol,
        sessionStorage: any AuthSessionStoringProtocol
    ) {
        self.authCoordinator = authCoordinator
        self.mainTabCoordinator = mainTabCoordinator
        self.authService = authService
        self.sessionStorage = sessionStorage
        
        self.route = (sessionStorage.userId != nil) ? .main : .auth
        
        storeChild(authCoordinator)
        storeChild(mainTabCoordinator)
        
        bind()
    }
    
    // MARK: - Coordinator Lifecycle
    
    func start() {
        guard !isStarted else { return }
        isStarted = true
        
        // Стартуем только нужный флоу, чтобы не было лишних стартов/финишей
        switch route {
        case .auth:
            authCoordinator.start()
        case .main:
            mainTabCoordinator.start()
        }
        
        bindAuthStateIfNeeded()
    }
    
    func finish() {
        isStarted = false
        bag.removeAll()
        
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
        guard route != .auth else { return }
        
        mainTabCoordinator.finish()
        route = .auth
        authCoordinator.start()
    }
    
    func showMain() {
        guard route != .main else { return }
        
        authCoordinator.finish()
        route = .main
        mainTabCoordinator.start()
    }
    
    // MARK: - Private
    
    private func bind() {
        mainTabCoordinator.onLogout = { [weak self] in
            self?.showAuth()
        }
    }
    
    private func bindAuthStateIfNeeded() {
        guard bag.isEmpty else { return }
        
        let base = authService.isAuthorizedPublisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
        
        let effective: AnyPublisher<Bool, Never>
        if route == .main {
            effective = base
                .dropFirst()
                .eraseToAnyPublisher()
        } else {
            effective = base
                .eraseToAnyPublisher()
        }
        
        effective
            .sink { [weak self] (isAuthorized: Bool) in
                guard let self else { return }
                isAuthorized ? self.showMain() : self.showAuth()
            }
            .store(in: &bag)
    }
}
