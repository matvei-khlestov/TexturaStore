//
//  FavoritesCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class FavoritesCoordinator: FavoritesCoordinating, @MainActor RoutableCoordinator {
    
    // MARK: - Routes
    
    typealias StackRoute = FavoritesRoute
    
    // MARK: - Coordinator
    
    var childCoordinators: [any CoordinatorBox] = []
    
    // MARK: - Router
    
    let router: AppRouter<FavoritesRoute, NoRoute, NoRoute> = AppRouter()
    
    // MARK: - Dependencies
    
    private let favoritesScreenFactory: any FavoritesScreenBuilding
    private let authService: any AuthServiceProtocol
    private let makeFavoritesViewModel: (String) -> any FavoritesViewModelProtocol
    
    // MARK: - Init
    
    init(
        favoritesScreenFactory: any FavoritesScreenBuilding,
        authService: any AuthServiceProtocol,
        makeFavoritesViewModel: @escaping (String) -> any FavoritesViewModelProtocol
    ) {
        self.favoritesScreenFactory = favoritesScreenFactory
        self.authService = authService
        self.makeFavoritesViewModel = makeFavoritesViewModel
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
        let userId = authService.currentUserId ?? ""
        let viewModel = makeFavoritesViewModel(userId)
        
        return favoritesScreenFactory.makeFavoritesView(
            viewModel: viewModel,
            onSelectProduct: { _ in
                // навигацию на детали добавишь позже
            }
        )
    }
    
    func buildStack(_ route: FavoritesRoute) -> AnyView {
        switch route {
        case .root:
            return makeRoot()
        }
    }
}
