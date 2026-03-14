//
//  ReviewsListViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation
import Combine

final class ReviewsListViewModel: ReviewsListViewModelProtocol {
    
    // MARK: - Deps
    
    private let reviewsRepository: any ReviewsRepository
    private let productId: String
    private let userId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var didBind = false
    
    private let reviewsSubject = CurrentValueSubject<[ProductReview], Never>([])
    private let canWriteReviewSubject = CurrentValueSubject<Bool, Never>(false)
    private let isDeletingSubject = CurrentValueSubject<Bool, Never>(false)
    private let deletingReviewIdSubject = CurrentValueSubject<String?, Never>(nil)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    
    // MARK: - Init
    
    init(
        reviewsRepository: any ReviewsRepository,
        productId: String,
        userId: String
    ) {
        self.reviewsRepository = reviewsRepository
        self.productId = productId
        self.userId = userId
    }
    
    // MARK: - State
    
    var reviews: [ProductReview] {
        reviewsSubject.value
    }
    
    var canWriteReview: Bool {
        canWriteReviewSubject.value
    }
    
    var isDeleting: Bool {
        isDeletingSubject.value
    }
    
    var deletingReviewId: String? {
        deletingReviewIdSubject.value
    }
    
    // MARK: - Publishers
    
    var reviewsPublisher: AnyPublisher<[ProductReview], Never> {
        reviewsSubject.eraseToAnyPublisher()
    }
    
    var canWriteReviewPublisher: AnyPublisher<Bool, Never> {
        canWriteReviewSubject.eraseToAnyPublisher()
    }
    
    var isDeletingPublisher: AnyPublisher<Bool, Never> {
        isDeletingSubject.eraseToAnyPublisher()
    }
    
    var deletingReviewIdPublisher: AnyPublisher<String?, Never> {
        deletingReviewIdSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Lifecycle
    
    func onAppear() {
        bindIfNeeded()
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await reviewsRepository.refresh(productId: productId)
            } catch {
                await MainActor.run {
                    self.errorSubject.send(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func isOwnReview(_ review: ProductReview) -> Bool {
        review.userId == userId
    }
    
    // MARK: - Actions
    
    func deleteReview(_ review: ProductReview) {
        guard !isDeleting else { return }
        guard isOwnReview(review) else { return }
        
        let previousReviews = reviewsSubject.value
        let updatedReviews = previousReviews.filter { $0.id != review.id }
        
        errorSubject.send(nil)
        isDeletingSubject.send(true)
        deletingReviewIdSubject.send(review.id)
        reviewsSubject.send(updatedReviews)
        updateCanWriteReview(with: updatedReviews)
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await reviewsRepository.remove(
                    uid: userId,
                    reviewId: review.id
                )
                
                await MainActor.run {
                    self.isDeletingSubject.send(false)
                    self.deletingReviewIdSubject.send(nil)
                }
            } catch {
                await MainActor.run {
                    self.reviewsSubject.send(previousReviews)
                    self.updateCanWriteReview(with: previousReviews)
                    self.isDeletingSubject.send(false)
                    self.deletingReviewIdSubject.send(nil)
                    self.errorSubject.send(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Private

private extension ReviewsListViewModel {
    
    func bindIfNeeded() {
        guard !didBind else { return }
        didBind = true
        
        reviewsRepository
            .observeReviews()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reviews in
                guard let self else { return }
                self.reviewsSubject.send(reviews)
                self.updateCanWriteReview(with: reviews)
            }
            .store(in: &bag)
    }
    
    func updateCanWriteReview(with reviews: [ProductReview]) {
        canWriteReviewSubject.send(
            !reviews.contains(where: { $0.userId == userId })
        )
    }
}
