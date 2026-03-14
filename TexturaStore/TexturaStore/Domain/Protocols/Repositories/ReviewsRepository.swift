//
//  ReviewsRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation
import Combine

/// Протокол `ReviewsRepository`
///
/// Определяет единый интерфейс для управления отзывами товара,
/// объединяя локальное (`ReviewsLocalStore`) и удалённое (`ReviewsStoreProtocol`)
/// хранилища данных.
///
/// Основные задачи:
/// - реактивное наблюдение за списком отзывов (`observeReviews`);
/// - синхронизация отзывов между сервером и локальным хранилищем (`refresh`);
/// - создание нового отзыва (`addReview`);
/// - обновление существующего отзыва (`updateReview`);
/// - удаление отзыва текущего пользователя (`remove`).
///
/// Используется в:
/// - ViewModel экрана отзывов товара;
/// - ViewModel карточки товара для отображения актуального количества отзывов и списка;
/// - сценариях создания и редактирования отзыва.
///
/// Репозиторий скрывает источник данных и обеспечивает согласованность
/// между локальной и удалённой копиями через Combine и async/await.
protocol ReviewsRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за локальным состоянием списка отзывов товара.
    /// - Returns: Паблишер, эмитирующий актуальный массив `ProductReview`.
    func observeReviews() -> AnyPublisher<[ProductReview], Never>
    
    // MARK: - Commands
    
    /// Выполняет обновление отзывов из удалённого источника
    /// и синхронизирует локальные данные.
    /// - Parameter productId: Идентификатор товара.
    func refresh(productId: String) async throws
    
    /// Создаёт новый отзыв.
    /// - Parameters:
    ///   - productId: Идентификатор товара.
    ///   - userId: Идентификатор пользователя.
    ///   - userName: Имя пользователя.
    ///   - rating: Оценка товара.
    ///   - comment: Текст комментария.
    func addReview(
        productId: String,
        userId: String,
        userName: String,
        rating: Int,
        comment: String
    ) async throws
    
    /// Обновляет существующий отзыв.
    /// - Parameters:
    ///   - reviewId: Идентификатор отзыва.
    ///   - productId: Идентификатор товара.
    ///   - userId: Идентификатор пользователя.
    ///   - userName: Имя пользователя.
    ///   - rating: Новая оценка.
    ///   - comment: Новый текст комментария.
    ///   - createdAt: Дата создания исходного отзыва.
    func updateReview(
        reviewId: String,
        productId: String,
        userId: String,
        userName: String,
        rating: Int,
        comment: String,
        createdAt: Date
    ) async throws
    
    /// Удаляет отзыв пользователя.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - reviewId: Идентификатор отзыва.
    func remove(uid: String, reviewId: String) async throws
}
