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
    
    // MARK: - Init
    
    init(
        catalogScreenFactory: any CatalogScreenBuilding,
        authService: any AuthServiceProtocol,
        makeCatalogViewModel: @escaping (String) -> any CatalogViewModelProtocol
    ) {
        self.catalogScreenFactory = catalogScreenFactory
        self.authService = authService
        self.makeCatalogViewModel = makeCatalogViewModel
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
        let viewModel = makeCatalogViewModel(userId)
        
        return catalogScreenFactory.makeCatalogView(
            viewModel: viewModel,
            onSelectProduct: { _ in },
            onFilterTap: { _ in },
            onSelectCategory: { _ in }
        )
    }
    
    func buildStack(_ route: CatalogRoute) -> AnyView {
        switch route {
        case .root:
            return makeRoot()
        }
    }
}
