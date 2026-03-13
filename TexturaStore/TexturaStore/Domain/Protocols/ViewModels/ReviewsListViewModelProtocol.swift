//
//  ReviewsListViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation
import Combine

protocol ReviewsListViewModelProtocol: AnyObject {
    
    // MARK: - State
    
    var reviews: [ProductReview] { get }
    var canWriteReview: Bool { get }
    var isDeleting: Bool { get }
    var deletingReviewId: String? { get }
    
    // MARK: - Publishers
    
    var reviewsPublisher: AnyPublisher<[ProductReview], Never> { get }
    var canWriteReviewPublisher: AnyPublisher<Bool, Never> { get }
    var isDeletingPublisher: AnyPublisher<Bool, Never> { get }
    var deletingReviewIdPublisher: AnyPublisher<String?, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    
    // MARK: - Lifecycle
    
    func onAppear()
    
    // MARK: - Helpers
    
    func isOwnReview(_ review: ProductReview) -> Bool
    
    // MARK: - Actions
    
    func deleteReview(_ review: ProductReview)
}
