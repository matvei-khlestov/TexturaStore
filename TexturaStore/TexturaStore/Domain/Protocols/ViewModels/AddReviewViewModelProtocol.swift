//
//  AddReviewViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation
import Combine

/// Протокол `AddReviewViewModelProtocol`.
///
/// Определяет контракт ViewModel экрана добавления отзыва.
///
/// Назначение:
/// - хранит и публикует состояние формы отзыва;
/// - обрабатывает ввод комментария и выбор рейтинга;
/// - валидирует данные перед отправкой;
/// - создаёт отзыв через `ReviewsRepository`;
/// - уведомляет View об успешном завершении сценария.
///
/// Используется в:
/// - `AddReviewView` как источник состояния и действий UI.
protocol AddReviewViewModelProtocol: AnyObject {
    
    // MARK: - State
    
    var comment: String { get }
    var rating: Int { get }
    var isSubmitting: Bool { get }
    
    // MARK: - Publishers
    
    var commentPublisher: AnyPublisher<String, Never> { get }
    var ratingPublisher: AnyPublisher<Int, Never> { get }
    var isSubmittingPublisher: AnyPublisher<Bool, Never> { get }
    var isSubmitEnabledPublisher: AnyPublisher<Bool, Never> { get }
    var commentErrorPublisher: AnyPublisher<String?, Never> { get }
    var ratingErrorPublisher: AnyPublisher<String?, Never> { get }
    var didSubmitPublisher: AnyPublisher<Void, Never> { get }
    
    // MARK: - Input
    
    func setComment(_ text: String)
    func setRating(_ rating: Int)
    
    // MARK: - Actions
    
    func submitReview()
}
