//
//  ProductDetailsNavigator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

@MainActor
final class ProductDetailsNavigator: ProductDetailsNavigating {
    
    // MARK: - Deps
    
    private let productDetailsScreenFactory: any ProductDetailsScreenBuilding
    private let authService: any AuthServiceProtocol
    private let makeProductDetailsViewModel: (String, String) -> any ProductDetailsViewModelProtocol
    
    // MARK: - Init
    
    init(
        productDetailsScreenFactory: any ProductDetailsScreenBuilding,
        authService: any AuthServiceProtocol,
        makeProductDetailsViewModel: @escaping (String, String) -> any ProductDetailsViewModelProtocol
    ) {
        self.productDetailsScreenFactory = productDetailsScreenFactory
        self.authService = authService
        self.makeProductDetailsViewModel = makeProductDetailsViewModel
    }
    
    // MARK: - Screens
    
    func makeRoot(
        productId: String,
        onBack: @escaping () -> Void
    ) -> AnyView {
        let userId = authService.currentUserId ?? ""
        let vm = makeProductDetailsViewModel(userId, productId)
        
        return productDetailsScreenFactory.makeProductDetailsView(
            viewModel: vm,
            onBack: onBack
        )
    }
    
    func makeDestination(
        route: ProductDetailsRoute,
        onBack: @escaping () -> Void
    ) -> AnyView {
        switch route {
        case .root(let productId):
            return makeRoot(
                productId: productId,
                onBack: onBack
            )
        }
    }
}
