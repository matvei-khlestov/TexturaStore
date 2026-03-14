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
    private let bootScreenFactory: BootScreenBuilding
    
    // MARK: - Subscriptions
    
    private var bag = Set<AnyCancellable>()
    private var isStarted = false
    
    // MARK: - Boot flow
    
    private var didHandleFirstAuthEmission = false
    private var bootFallbackTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(
        authCoordinator: any AuthCoordinating,
        mainTabCoordinator: any MainTabCoordinating,
        authService: any AuthServiceProtocol,
        sessionStorage: any AuthSessionStoringProtocol,
        bootScreenFactory: BootScreenBuilding
    ) {
        self.authCoordinator = authCoordinator
        self.mainTabCoordinator = mainTabCoordinator
        self.authService = authService
        self.sessionStorage = sessionStorage
        self.bootScreenFactory = bootScreenFactory
        
        self.route = .boot
        
        storeChild(authCoordinator)
        storeChild(mainTabCoordinator)
        
        bind()
    }
    
    deinit {
        bootFallbackTask?.cancel()
        bootFallbackTask = nil
    }
    
    // MARK: - Coordinator Lifecycle
    
    func start() {
        guard !isStarted else { return }
        isStarted = true
        
        bindAuthStateIfNeeded()
        startBootFallbackIfNeeded()
    }
    
    func finish() {
        isStarted = false
        bag.removeAll()
        
        bootFallbackTask?.cancel()
        bootFallbackTask = nil
        
        authCoordinator.finish()
        mainTabCoordinator.finish()
        
        removeAllChildren()
    }
    
    // MARK: - Root View
    
    var rootView: AnyView {
        AnyView(
            Group {
                switch route {
                case .boot:
                    bootScreenFactory.makeBootView()
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
    
    private var hasStoredSession: Bool {
        guard let access = sessionStorage.accessToken,
              let refresh = sessionStorage.refreshToken else {
            return false
        }
        return !access.isEmpty && !refresh.isEmpty
    }
    
    private func startBootFallbackIfNeeded() {
        bootFallbackTask?.cancel()
        bootFallbackTask = nil
        
        guard hasStoredSession else {
            showAuth()
            return
        }
        
        bootFallbackTask = Task { [weak self] in
            guard let self else { return }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled { return }
            
            if self.route == .boot {
                self.showAuth()
            }
        }
    }
    
    private func bindAuthStateIfNeeded() {
        guard bag.isEmpty else { return }
        
        authService.isAuthorizedPublisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isAuthorized in
                guard let self else { return }
                
                if !self.didHandleFirstAuthEmission {
                    self.didHandleFirstAuthEmission = true
                    
                    if self.route == .boot,
                       self.hasStoredSession,
                       isAuthorized == false {
                        return
                    }
                }
                
                if isAuthorized {
                    self.bootFallbackTask?.cancel()
                    self.bootFallbackTask = nil
                    self.showMain()
                } else {
                    if self.route != .boot {
                        self.showAuth()
                    }
                }
            }
            .store(in: &bag)
    }
}
