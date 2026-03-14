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
    
    private let productDetailsNavigator: any ProductDetailsNavigating
    
    // MARK: - Init
    
    init(
        favoritesScreenFactory: any FavoritesScreenBuilding,
        authService: any AuthServiceProtocol,
        makeFavoritesViewModel: @escaping (String) -> any FavoritesViewModelProtocol,
        productDetailsNavigator: any ProductDetailsNavigating
    ) {
        self.favoritesScreenFactory = favoritesScreenFactory
        self.authService = authService
        self.makeFavoritesViewModel = makeFavoritesViewModel
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
        let viewModel = makeFavoritesViewModel(userId)
        
        return favoritesScreenFactory.makeFavoritesView(
            viewModel: viewModel,
            onSelectProduct: { [weak self] productId in
                self?.router.push(.productDetails(.root(productId: productId)))
            }
        )
    }
    
    func buildStack(_ route: FavoritesRoute) -> AnyView {
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
}
