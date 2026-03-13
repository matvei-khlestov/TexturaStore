//
//  ProductDetailsScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

@MainActor
final class ProductDetailsScreenFactory: ProductDetailsScreenBuilding {
    
    func makeProductDetailsView(
        viewModel: ProductDetailsViewModelProtocol,
        onBack: (() -> Void)?,
        onOpenReviews: (() -> Void)?,
        onWriteReview: (() -> Void)?
    ) -> AnyView {
        AnyView(
            ProductDetailsView(
                viewModel: viewModel,
                onBack: onBack,
                onOpenReviews: onOpenReviews,
                onWriteReview: onWriteReview
            )
        )
    }
    
    func makeAddReviewView(
        viewModel: AddReviewViewModelProtocol,
        onBack: (() -> Void)?
    ) -> AnyView {
        AnyView(
            AddReviewView(
                viewModel: viewModel,
                onBack: onBack
            )
        )
    }
    
    func makeReviewsListView(
        viewModel: ReviewsListViewModelProtocol,
        onBack: (() -> Void)?,
        onWriteReview: (() -> Void)?
    ) -> AnyView {
        AnyView(
            ReviewsListView(
                viewModel: viewModel,
                onBack: onBack,
                onWriteReview: onWriteReview
            )
        )
    }
}
