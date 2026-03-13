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
                
                Text("Отзывы о товаре (\(reviews.count))")
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
            "Удалить отзыв?",
            isPresented: Binding(
                get: { reviewToDelete != nil },
                set: { if !$0 { reviewToDelete = nil } }
            )
        ) {
            Button("Удалить", role: .destructive) {
                guard let reviewToDelete else { return }
                viewModel.deleteReview(reviewToDelete)
                self.reviewToDelete = nil
            }
            
            Button("Отмена", role: .cancel) {
                reviewToDelete = nil
            }
        } message: {
            Text("Это действие нельзя отменить.")
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

// MARK: - ReviewRow

private struct ReviewRow: View {
    
    let review: ProductReview
    let isOwnReview: Bool
    let isDeleting: Bool
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Text(formattedDate(review.createdAt))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.brand)
                    
                    Text("\(review.rating)")
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
            
            Text(review.comment ?? "—")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(uiColor: .label))
                .multilineTextAlignment(.leading)
            
            if isOwnReview {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Text("Удалить отзыв")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.red)
                }
                .disabled(isDeleting)
            }
        }
        .padding(.vertical, 18)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
