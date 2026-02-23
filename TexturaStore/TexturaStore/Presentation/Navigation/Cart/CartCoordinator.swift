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
    
    private let productDetailsNavigator: any ProductDetailsNavigating
    
    // MARK: - Init
    
    init(
        cartScreenFactory: any CartScreenBuilding,
        authService: any AuthServiceProtocol,
        makeCartViewModel: @escaping (String) -> any CartViewModelProtocol,
        productDetailsNavigator: any ProductDetailsNavigating
    ) {
        self.cartScreenFactory = cartScreenFactory
        self.authService = authService
        self.makeCartViewModel = makeCartViewModel
        self.productDetailsNavigator = productDetailsNavigator
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
                // checkout подключишь позже
                _ = self
            },
            onSelectProductId: { [weak self] productId in
                self?.router.push(.productDetails(.root(productId: productId)))
            }
        )
    }
    
    func buildStack(_ route: CartRoute) -> AnyView {
        switch route {
            
        case .root:
            return makeRoot()
            
        case .productDetails(let detailsRoute):
            return buildProductDetailsRoute(detailsRoute)
        }
    }
    
    // MARK: - Private
    
    private func buildProductDetailsRoute(
        _ route: ProductDetailsRoute
    ) -> AnyView {
        switch route {
        case .root:
            return productDetailsNavigator.makeDestination(
                route: route,
                onBack: { [weak self] in
                    self?.router.pop()
                }
            )
        }
    }
}
