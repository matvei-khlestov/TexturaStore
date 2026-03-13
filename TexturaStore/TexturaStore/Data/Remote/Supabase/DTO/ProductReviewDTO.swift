//
//  ProductReviewDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation

/// Data Transfer Object, описывающий отзыв на товар (`ProductReviewDTO`) в слое данных.
///
/// Назначение:
/// - используется для получения и передачи данных отзывов из Supabase (PostgreSQL);
/// - изолирует сетевой формат от доменной модели `ProductReview`;
/// - участвует в синхронизации отзывов товара.
///
/// Состав:
/// - `id`: уникальный идентификатор отзыва;
/// - `productId`: идентификатор товара;
/// - `userId`: идентификатор пользователя, оставившего отзыв;
/// - `rating`: оценка товара (1–5);
/// - `comment`: текст комментария пользователя;
/// - `userName`: отображаемое имя пользователя;
/// - `createdAt`, `updatedAt`: даты создания и обновления отзыва.
///
/// Особенности реализации:
/// - поддерживает `Codable` для декодирования ответов Supabase;
/// - ключи соответствуют `snake_case` полям таблицы;
/// - преобразуется в доменную модель через `toEntity()`.
struct ProductReviewDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let id: String
    let productId: String
    let userId: String
    let rating: Int
    let comment: String?
    let userName: String
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Mapping
    
    func toEntity() -> ProductReview {
        ProductReview(
            id: id,
            productId: productId,
            userId: userId,
            rating: rating,
            comment: comment,
            userName: userName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CodingKeys

private extension ProductReviewDTO {
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case userId = "user_id"
        case rating
        case comment
        case userName = "user_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
