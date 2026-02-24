//
//  CatalogCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class CatalogCoordinator: CatalogCoordinating, @MainActor RoutableCoordinator {
    
    // MARK: - Routes
    
    typealias StackRoute = CatalogRoute
    
    // MARK: - Coordinator
    
    var childCoordinators: [any CoordinatorBox] = []
    
    // MARK: - Router
    
    let router: AppRouter<CatalogRoute, NoRoute, NoRoute> = AppRouter()
    
    // MARK: - Dependencies
    
    private let catalogScreenFactory: any CatalogScreenBuilding
    private let authService: any AuthServiceProtocol
    private let makeCatalogViewModel: (String) -> any CatalogViewModelProtocol
    
    private let categoryProductsNavigator: any CategoryProductsNavigating
    private let productDetailsNavigator: any ProductDetailsNavigating
    
    // MARK: - Localization
    
    private let languageProvider: any LanguageProviding
    private let localizer: any CatalogLocalizing
    
    // MARK: - Init
    
    init(
        catalogScreenFactory: any CatalogScreenBuilding,
        authService: any AuthServiceProtocol,
        makeCatalogViewModel: @escaping (String) -> any CatalogViewModelProtocol,
        categoryProductsNavigator: any CategoryProductsNavigating,
        productDetailsNavigator: any ProductDetailsNavigating,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)? = nil
    ) {
        self.catalogScreenFactory = catalogScreenFactory
        self.authService = authService
        self.makeCatalogViewModel = makeCatalogViewModel
        self.categoryProductsNavigator = categoryProductsNavigator
        self.productDetailsNavigator = productDetailsNavigator
        
        self.languageProvider = languageProvider
        self.localizer = localizer ?? DefaultCatalogLocalizer(languageProvider: languageProvider)
    }
    
    // MARK: - Lifecycle
    
    func start() {
        router.resetAll()
    }
    
    func finish() {
        router.resetAll()
        removeAllChildren()
    }
    
    // MARK: - Root
    
    func makeRoot() -> AnyView {
        let userId = authService.currentUserId ?? ""
        let viewModel = makeCatalogViewModel(userId)
        
        return catalogScreenFactory.makeCatalogView(
            viewModel: viewModel,
            languageProvider: languageProvider,
            localizer: localizer,
            onSelectProduct: { [weak self] product in
                self?.router.push(.productDetails(.root(productId: product.id)))
            },
            onFilterTap: { _ in
                // filters later
            },
            onSelectCategory: { [weak self] category in
                guard let self else { return }
                let title = self.localizer.categoryTitle(category)
                self.router.push(.categoryProducts(.root(
                    categoryId: category.id,
                    title: title
                )))
            }
        )
    }
    
    // MARK: - Stack
    
    func buildStack(_ route: CatalogRoute) -> AnyView {
        switch route {
        case .root:
            return makeRoot()
            
        case .categoryProducts(let route):
            return buildCategoryProductsRoute(route)
            
        case .productDetails(let route):
            return buildProductDetailsRoute(route)
        }
    }
    
    // MARK: - Builders
    
    private func buildCategoryProductsRoute(_ route: CategoryProductsRoute) -> AnyView {
        switch route {
        case .root(let categoryId, let title):
            return categoryProductsNavigator.makeRoot(
                categoryId: categoryId,
                title: title,
                onBack: { [weak self] in self?.router.pop() },
                onSelectProduct: { [weak self] product in
                    self?.router.push(.productDetails(.root(productId: product.id)))
                }
            )
        }
    }
    
    private func buildProductDetailsRoute(_ route: ProductDetailsRoute) -> AnyView {
        switch route {
        case .root:
            return productDetailsNavigator.makeDestination(
                route: route,
                onBack: { [weak self] in self?.router.pop() }
            )
        }
    }
}
