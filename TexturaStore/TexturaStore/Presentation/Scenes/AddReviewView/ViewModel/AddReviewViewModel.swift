//
//  AddReviewViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation
import Combine

/// ViewModel экрана добавления отзыва.
///
/// Назначение:
/// - управляет состоянием формы добавления отзыва;
/// - принимает ввод текста комментария и рейтинга;
/// - валидирует введённые данные;
/// - отправляет данные отзыва через `ReviewsRepository`;
/// - получает имя пользователя из `ProfileRepository`;
/// - уведомляет экран об успешной отправке, чтобы выполнить возврат назад.
///
/// Используется в:
/// - `AddReviewView`.
final class AddReviewViewModel: AddReviewViewModelProtocol {
    
    // MARK: - Deps
    
    private let reviewsRepository: any ReviewsRepository
    private let profileRepository: any ProfileRepository
    private let validator: FormValidatingProtocol
    
    private let productId: String
    private let userId: String
    
    // MARK: - Subjects
    
    private let commentSubject = CurrentValueSubject<String, Never>("")
    private let ratingSubject = CurrentValueSubject<Int, Never>(0)
    private let isSubmittingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isSubmitEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let commentErrorSubject = CurrentValueSubject<String?, Never>(nil)
    private let ratingErrorSubject = CurrentValueSubject<String?, Never>(nil)
    private let didSubmitSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Init
    
    init(
        repository: any ReviewsRepository,
        profileRepository: any ProfileRepository,
        productId: String,
        userId: String,
        validator: FormValidatingProtocol
    ) {
        self.reviewsRepository = repository
        self.profileRepository = profileRepository
        self.productId = productId
        self.userId = userId
        self.validator = validator
        
        updateSubmitState()
    }
    
    // MARK: - State
    
    var comment: String {
        commentSubject.value
    }
    
    var rating: Int {
        ratingSubject.value
    }
    
    var isSubmitting: Bool {
        isSubmittingSubject.value
    }
    
    // MARK: - Publishers
    
    var commentPublisher: AnyPublisher<String, Never> {
        commentSubject.eraseToAnyPublisher()
    }
    
    var ratingPublisher: AnyPublisher<Int, Never> {
        ratingSubject.eraseToAnyPublisher()
    }
    
    var isSubmittingPublisher: AnyPublisher<Bool, Never> {
        isSubmittingSubject.eraseToAnyPublisher()
    }
    
    var isSubmitEnabledPublisher: AnyPublisher<Bool, Never> {
        isSubmitEnabledSubject.eraseToAnyPublisher()
    }
    
    var commentErrorPublisher: AnyPublisher<String?, Never> {
        commentErrorSubject.eraseToAnyPublisher()
    }
    
    var ratingErrorPublisher: AnyPublisher<String?, Never> {
        ratingErrorSubject.eraseToAnyPublisher()
    }
    
    var didSubmitPublisher: AnyPublisher<Void, Never> {
        didSubmitSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Input
    
    func setComment(_ text: String) {
        commentSubject.send(text)
        commentErrorSubject.send(nil)
        updateSubmitState()
    }
    
    func setRating(_ rating: Int) {
        let normalized = min(max(rating, 0), 5)
        ratingSubject.send(normalized)
        ratingErrorSubject.send(nil)
        updateSubmitState()
    }
    
    // MARK: - Actions
    
    func submitReview() {
        guard !isSubmitting else { return }
        guard validate() else { return }
        
        let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        
        isSubmittingSubject.send(true)
        updateSubmitState()
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let profile = try await loadProfile()
                
                try await reviewsRepository.addReview(
                    productId: productId,
                    userId: userId,
                    userName: profile.name,
                    rating: rating,
                    comment: trimmedComment
                )
                
                await MainActor.run {
                    self.isSubmittingSubject.send(false)
                    self.updateSubmitState()
                    self.didSubmitSubject.send(())
                }
            } catch {
                await MainActor.run {
                    self.isSubmittingSubject.send(false)
                    self.commentErrorSubject.send(error.localizedDescription)
                    self.updateSubmitState()
                }
            }
        }
    }
}

// MARK: - Private

private extension AddReviewViewModel {
    
    func validate() -> Bool {
        var isValid = true
        
        let commentResult = validator.validate(comment, for: .comment)
        if !commentResult.isValid {
            commentErrorSubject.send(commentResult.message)
            isValid = false
        } else {
            commentErrorSubject.send(nil)
        }
        
        if rating <= 0 {
            ratingErrorSubject.send("Поставьте оценку товару")
            isValid = false
        } else {
            ratingErrorSubject.send(nil)
        }
        
        return isValid
    }
    
    func updateSubmitState() {
        let canSubmit = !isSubmitting
        isSubmitEnabledSubject.send(canSubmit)
    }
    
    func loadProfile() async throws -> Profile {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = profileRepository
                .observeProfile()
                .first(where: { $0 != nil })
                .sink { profile in
                    guard let profile else {
                        continuation.resume(
                            throwing: AddReviewViewModelError.profileUnavailable
                        )
                        cancellable?.cancel()
                        return
                    }
                    
                    continuation.resume(returning: profile)
                    cancellable?.cancel()
                }
        }
    }
}

// MARK: - Error

private extension AddReviewViewModel {
    
    enum AddReviewViewModelError: LocalizedError {
        case profileUnavailable
        
        var errorDescription: String? {
            switch self {
            case .profileUnavailable:
                return "Не удалось получить профиль пользователя"
            }
        }
    }
}
