//
//  ReviewsListView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import SwiftUI
import Combine

struct ReviewsListView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onWriteReview: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: ReviewsListViewModelProtocol
    
    // MARK: - State
    
    @State private var reviews: [ProductReview]
    @State private var canWriteReview: Bool
    @State private var deletingReviewId: String?
    @State private var isDeleting: Bool
    @State private var reviewToDelete: ProductReview?
    
    // MARK: - Init
    
    init(
        viewModel: ReviewsListViewModelProtocol,
        onBack: (() -> Void)? = nil,
        onWriteReview: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onWriteReview = onWriteReview
        
        _reviews = State(initialValue: viewModel.reviews)
        _canWriteReview = State(initialValue: viewModel.canWriteReview)
        _deletingReviewId = State(initialValue: viewModel.deletingReviewId)
        _isDeleting = State(initialValue: viewModel.isDeleting)
        _reviewToDelete = State(initialValue: nil)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text(L10n.ReviewsList.Navigation.title(reviews.count))
                    .font(.system(size: 25, weight: .bold))
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(reviews, id: \.id) { review in
                        ReviewRow(
                            review: review,
                            isOwnReview: viewModel.isOwnReview(review),
                            isDeleting: deletingReviewId == review.id && isDeleting,
                            onDelete: {
                                reviewToDelete = review
                            }
                        )
                        
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 25)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarBackButtonHidden(true)
        .brandBackButton {
            onBack?()
        }
        .navigationBarItems(
            trailing: addButton
        )
        .onAppear {
            viewModel.onAppear()
        }
        .onReceive(viewModel.reviewsPublisher) {
            reviews = $0
        }
        .onReceive(viewModel.canWriteReviewPublisher) {
            canWriteReview = $0
        }
        .onReceive(viewModel.deletingReviewIdPublisher) {
            deletingReviewId = $0
        }
        .onReceive(viewModel.isDeletingPublisher) {
            isDeleting = $0
        }
        .alert(
            L10n.ReviewsList.Alert.Delete.title,
            isPresented: Binding(
                get: { reviewToDelete != nil },
                set: { if !$0 { reviewToDelete = nil } }
            )
        ) {
            Button(L10n.ReviewsList.Alert.Delete.confirm, role: .destructive) {
                guard let reviewToDelete else { return }
                viewModel.deleteReview(reviewToDelete)
                self.reviewToDelete = nil
            }
            
            Button(L10n.ReviewsList.Alert.Delete.cancel, role: .cancel) {
                reviewToDelete = nil
            }
        } message: {
            Text(L10n.ReviewsList.Alert.Delete.message)
        }
    }
}

// MARK: - Navigation Items

private extension ReviewsListView {
    
    @ViewBuilder
    var addButton: some View {
        if canWriteReview {
            Button {
                onWriteReview?()
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(Color(uiColor: .label))
            }
        } else {
            EmptyView()
        }
    }
}
