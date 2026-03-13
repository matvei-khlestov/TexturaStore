//
//  ReviewsLocalStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//


import Combine

/// Протокол локального слоя хранения отзывов.
///
/// Назначение:
/// - предоставляет доступ к локальному кешу отзывов в Core Data;
/// - поддерживает реактивное наблюдение за отзывами конкретного товара;
/// - инкапсулирует операции сохранения, обновления, удаления и очистки отзывов.
///
/// Используется в:
/// - `CoreDataReviewsStore` как concrete-реализация;
/// - `DefaultReviewsRepository` для синхронизации удалённого и локального слоёв.
protocol ReviewsLocalStore: AnyObject {
    
    /// Реактивно наблюдает за отзывами товара из локального хранилища.
    /// - Parameter productId: Идентификатор товара.
    /// - Returns: Паблишер массива доменных моделей `ProductReview`.
    func listen(productId: String) -> AnyPublisher<[ProductReview], Never>
    
    /// Одноразово читает локальный кеш отзывов товара.
    /// - Parameter productId: Идентификатор товара.
    /// - Returns: Массив доменных моделей `ProductReview`.
    func fetch(productId: String) -> [ProductReview]
    
    /// Сохраняет новый отзыв в локальное хранилище.
    /// - Parameter dto: DTO отзыва.
    func add(dto: ProductReviewDTO)
    
    /// Обновляет существующий отзыв в локальном хранилище.
    /// - Parameter dto: DTO отзыва.
    func update(dto: ProductReviewDTO)
    
    /// Удаляет отзыв из локального хранилища.
    /// - Parameter reviewId: Идентификатор отзыва.
    func remove(reviewId: String)
    
    /// Полностью заменяет локальный кеш отзывов товара актуальным списком.
    /// - Parameters:
    ///   - productId: Идентификатор товара.
    ///   - dtos: Актуальный список отзывов.
    func replace(productId: String, with dtos: [ProductReviewDTO])
    
    /// Полностью очищает локальный кеш отзывов товара.
    /// - Parameter productId: Идентификатор товара.
    func clear(productId: String)
}
