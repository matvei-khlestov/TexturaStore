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
    private let checkoutNavigator: any CheckoutNavigating
    
    // MARK: - Init
    
    init(
        cartScreenFactory: any CartScreenBuilding,
        authService: any AuthServiceProtocol,
        makeCartViewModel: @escaping (String) -> any CartViewModelProtocol,
        productDetailsNavigator: any ProductDetailsNavigating,
        checkoutNavigator: any CheckoutNavigating
    ) {
        self.cartScreenFactory = cartScreenFactory
        self.authService = authService
        self.makeCartViewModel = makeCartViewModel
        self.productDetailsNavigator = productDetailsNavigator
        self.checkoutNavigator = checkoutNavigator
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
            onCheckout: { [weak self, weak viewModel] in
                guard let self, let viewModel else { return }
                router.push(.checkout(.root, snapshotItems: viewModel.itemsSnapshot))
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
            
        case .checkout(let checkoutRoute, let snapshotItems):
            return buildCheckoutRoute(
                checkoutRoute,
                snapshotItems: snapshotItems
            )
        }
    }
    
    // MARK: - Private
    
    private func buildProductDetailsRoute(
        _ route: ProductDetailsRoute
    ) -> AnyView {
        switch route {
            
        case .root(let productId):
            let userId = authService.currentUserId ?? ""
            
            return productDetailsNavigator.makeRoot(
                productId: productId,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onOpenReviews: { [weak self] in
                    guard let self else { return }
                    
                    self.router.push(
                        .productDetails(
                            .reviewsList(
                                productId: productId,
                                userId: userId
                            )
                        )
                    )
                },
                onWriteReview: { [weak self] in
                    guard let self else { return }
                    
                    self.router.push(
                        .productDetails(
                            .addReview(
                                productId: productId,
                                userId: userId
                            )
                        )
                    )
                }
            )
            
        case .reviewsList(let productId, let userId):
            return productDetailsNavigator.makeDestination(
                route: route,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onWriteReview: { [weak self] in
                    guard let self else { return }
                    
                    self.router.push(
                        .productDetails(
                            .addReview(
                                productId: productId,
                                userId: userId
                            )
                        )
                    )
                }
            )
            
        case .addReview:
            return productDetailsNavigator.makeDestination(
                route: route,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onWriteReview: { }
            )
        }
    }
    
    private func buildCheckoutRoute(
        _ route: CheckoutRoute,
        snapshotItems: [CartItem]
    ) -> AnyView {
        checkoutNavigator.makeDestination(
            route: route,
            snapshotItems: snapshotItems,
            onBack: { [weak self] in
                self?.router.pop()
            },
            onFinish: { [weak self] in
                self?.router.push(.checkout(.success, snapshotItems: snapshotItems))
            },
            onViewCatalog: { [weak self] in
                self?.router.popToRoot()
            }
        )
    }
}
