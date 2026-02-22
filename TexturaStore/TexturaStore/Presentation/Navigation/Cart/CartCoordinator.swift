//
//  CartCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class CartCoordinator: CartCoordinating, @MainActor RoutableCoordinator {
    
    // MARK: - Routes
    
    typealias StackRoute = CartRoute
    
    // MARK: - Coordinator
    
    var childCoordinators: [any CoordinatorBox] = []
    
    // MARK: - Router
    
    let router: AppRouter<CartRoute, NoRoute, NoRoute> = AppRouter()
    
    // MARK: - Dependencies
    
    private let cartScreenFactory: any CartScreenBuilding
    private let authService: any AuthServiceProtocol
    private let makeCartViewModel: (String) -> any CartViewModelProtocol
    
    // MARK: - Init
    
    init(
        cartScreenFactory: any CartScreenBuilding,
        authService: any AuthServiceProtocol,
        makeCartViewModel: @escaping (String) -> any CartViewModelProtocol
    ) {
        self.cartScreenFactory = cartScreenFactory
        self.authService = authService
        self.makeCartViewModel = makeCartViewModel
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
        let viewModel = makeCartViewModel(userId)
        
        return cartScreenFactory.makeCartView(
            viewModel: viewModel,
            onCheckout: { [weak self] in
                // навигацию на checkout добавишь позже
                _ = self
            },
            onSelectProductId: { _ in
                // навигацию на детали добавишь позже
            }
        )
    }
    
    func buildStack(_ route: CartRoute) -> AnyView {
        switch route {
        case .root:
            return makeRoot()
        }
    }
}
