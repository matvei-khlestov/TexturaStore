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
    
    private let makeReviewsListViewModel: (
        String,
        String
    ) -> any ReviewsListViewModelProtocol
    
    private let makeAddReviewViewModel: (
        String,
        String
    ) -> any AddReviewViewModelProtocol
    
    // MARK: - Init
    
    init(
        productDetailsScreenFactory: any ProductDetailsScreenBuilding,
        authService: any AuthServiceProtocol,
        makeProductDetailsViewModel: @escaping (String, String) -> any ProductDetailsViewModelProtocol,
        makeReviewsListViewModel: @escaping (
            String,
            String
        ) -> any ReviewsListViewModelProtocol,
        makeAddReviewViewModel: @escaping (
            String,
            String
        ) -> any AddReviewViewModelProtocol
    ) {
        self.productDetailsScreenFactory = productDetailsScreenFactory
        self.authService = authService
        self.makeProductDetailsViewModel = makeProductDetailsViewModel
        self.makeReviewsListViewModel = makeReviewsListViewModel
        self.makeAddReviewViewModel = makeAddReviewViewModel
    }
    
    // MARK: - Screens
    
    func makeRoot(
        productId: String,
        onBack: @escaping () -> Void,
        onOpenReviews: @escaping () -> Void,
        onWriteReview: @escaping () -> Void
    ) -> AnyView {
        let userId = authService.currentUserId ?? ""
        let vm = makeProductDetailsViewModel(userId, productId)
        
        return productDetailsScreenFactory.makeProductDetailsView(
            viewModel: vm,
            onBack: onBack,
            onOpenReviews: onOpenReviews,
            onWriteReview: onWriteReview
        )
    }
    
    func makeDestination(
        route: ProductDetailsRoute,
        onBack: @escaping () -> Void,
        onWriteReview: @escaping () -> Void
    ) -> AnyView {
        switch route {
            
        case .root(let productId):
            return makeRoot(
                productId: productId,
                onBack: onBack,
                onOpenReviews: {},
                onWriteReview: onWriteReview
            )
            
        case .reviewsList(
            let productId,
            let userId
        ):
            let vm = makeReviewsListViewModel(
                productId,
                userId
            )
            
            return productDetailsScreenFactory.makeReviewsListView(
                viewModel: vm,
                onBack: onBack,
                onWriteReview: onWriteReview
            )
            
        case .addReview(
            let productId,
            let userId
        ):
            let vm = makeAddReviewViewModel(
                productId,
                userId
            )
            
            return productDetailsScreenFactory.makeAddReviewView(
                viewModel: vm,
                onBack: onBack
            )
        }
    }
}
