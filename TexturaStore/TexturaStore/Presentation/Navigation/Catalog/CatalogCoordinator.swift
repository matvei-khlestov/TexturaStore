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
    
    private let makeCatalogFilterViewModel: () -> any CatalogFilterViewModelProtocol
    
    private let categoryProductsNavigator: any CategoryProductsNavigating
    private let productDetailsNavigator: any ProductDetailsNavigating
    
    // MARK: - Localization
    
    private let languageProvider: any LanguageProviding
    private let localizer: any CatalogLocalizing
    
    // MARK: - Stored
    
    private var catalogViewModel: (any CatalogViewModelProtocol)?
    private var lastKnownFilterState: FilterState = .init()
    
    // MARK: - Init
    
    init(
        catalogScreenFactory: any CatalogScreenBuilding,
        authService: any AuthServiceProtocol,
        makeCatalogViewModel: @escaping (String) -> any CatalogViewModelProtocol,
        makeCatalogFilterViewModel: @escaping () -> any CatalogFilterViewModelProtocol,
        categoryProductsNavigator: any CategoryProductsNavigating,
        productDetailsNavigator: any ProductDetailsNavigating,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)? = nil
    ) {
        self.catalogScreenFactory = catalogScreenFactory
        self.authService = authService
        self.makeCatalogViewModel = makeCatalogViewModel
        
        self.makeCatalogFilterViewModel = makeCatalogFilterViewModel
        
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
        catalogViewModel = nil
        lastKnownFilterState = .init()
    }
    
    // MARK: - Root
    
    func makeRoot() -> AnyView {
        let viewModel: any CatalogViewModelProtocol
        
        if let cached = catalogViewModel {
            viewModel = cached
        } else {
            let userId = authService.currentUserId ?? ""
            let created = makeCatalogViewModel(userId)
            catalogViewModel = created
            viewModel = created
        }
        
        return catalogScreenFactory.makeCatalogView(
            viewModel: viewModel,
            languageProvider: languageProvider,
            localizer: localizer,
            onSelectProduct: { [weak self] product in
                self?.router.push(.productDetails(.root(productId: product.id)))
            },
            onFilterTap: { [weak self] _ in
                self?.router.push(.filter)
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
            
        case .filter:
            return buildFilterRoute()
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
        case .root(let productId):
            return productDetailsNavigator.makeRoot(
                productId: productId,
                onBack: { [weak self] in
                    self?.router.pop()
                },
                onOpenReviews: { [weak self] in
                    guard let self else { return }
                    
                    let userId = self.authService.currentUserId ?? ""
                    
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
                    
                    let userId = self.authService.currentUserId ?? ""
                    
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
        }
    }
    
    // MARK: - Filter
    
    private func buildFilterRoute() -> AnyView {
        guard let catalogVM = catalogViewModel else {
            let filterVM = makeCatalogFilterViewModel()
            return catalogScreenFactory.makeCatalogFilterView(
                viewModel: filterVM,
                initialState: lastKnownFilterState,
                languageProvider: languageProvider,
                localizer: localizer,
                onBack: { [weak self] in self?.router.pop() },
                onApply: { [weak self] state in
                    self?.lastKnownFilterState = state
                    self?.router.pop()
                }
            )
        }
        
        let initialState = catalogVM.currentState
        lastKnownFilterState = initialState
        
        let filterVM = makeCatalogFilterViewModel()
        
        return catalogScreenFactory.makeCatalogFilterView(
            viewModel: filterVM,
            initialState: initialState,
            languageProvider: languageProvider,
            localizer: localizer,
            onBack: { [weak self] in
                self?.router.pop()
            },
            onApply: { [weak self] state in
                guard let self else { return }
                
                self.lastKnownFilterState = state
                catalogVM.applyFilters(state)
                self.router.pop()
            }
        )
    }
}
