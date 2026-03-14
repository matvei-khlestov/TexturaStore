//
//  CDProductReview+Mapper.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import CoreData

/// Расширение `CDProductReview`, реализующее маппинг между Core Data и Domain слоями.
///
/// Назначение:
/// - применяет данные из `ProductReviewDTO` к сущности Core Data `CDProductReview`
///   для локального кеширования отзывов;
/// - предоставляет сравнение `matches(_:)` для предотвращения избыточных обновлений;
/// - позволяет собрать доменную модель `ProductReview` из `CDProductReview`.
///
/// Используется в:
/// - `CoreDataReviewsStore` как локальный слой хранения отзывов;
/// - `DefaultReviewsRepository` для синхронизации отзывов Supabase ↔︎ Core Data.
extension CDProductReview {
    
    /// Применяет данные из `ProductReviewDTO` к Core Data сущности `CDProductReview`.
    /// - Parameter dto: DTO отзыва, полученный из Supabase.
    func apply(dto: ProductReviewDTO) {
        id = dto.id
        productId = dto.productId
        userId = dto.userId
        rating = Int32(dto.rating)
        comment = dto.comment
        userName = dto.userName
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение полей сущности с переданным DTO.
    /// Используется для предотвращения избыточных обновлений.
    /// - Parameter dto: DTO для сравнения.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: ProductReviewDTO) -> Bool {
        (id ?? "") == dto.id
        && (productId ?? "") == dto.productId
        && (userId ?? "") == dto.userId
        && rating == Int32(dto.rating)
        && comment == dto.comment
        && (userName ?? "") == dto.userName
        && (createdAt ?? .distantPast) == dto.createdAt
        && (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `ProductReview`, предоставляющее инициализацию
/// доменной модели на основе Core Data сущности `CDProductReview`.
///
/// Выполняет безопасное извлечение данных и создание `ProductReview`
/// с сохранением типов дат (`Date`) в Domain-слое.
extension ProductReview {
    
    /// Инициализирует доменную модель `ProductReview` из Core Data сущности `CDProductReview`.
    /// - Parameter cd: Core Data объект `CDProductReview`.
    init?(cd: CDProductReview?) {
        guard
            let cd,
            let id = cd.id,
            let productId = cd.productId,
            let userId = cd.userId,
            let userName = cd.userName,
            let createdAt = cd.createdAt,
            let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            productId: productId,
            userId: userId,
            rating: Int(cd.rating),
            comment: cd.comment,
            userName: userName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
