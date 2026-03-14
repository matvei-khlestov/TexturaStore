//
//  CartDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation

/// Data Transfer Object, описывающий элемент корзины (`CartDTO`).
///
/// Назначение:
/// - используется для обмена данными между Supabase (PostgREST / Realtime) и локальным хранилищем (Core Data);
/// - изолирует сетевые структуры данных от доменных моделей и UI.
///
/// Состав:
/// - `userId`: идентификатор пользователя, владельца корзины;
/// - `productId`: идентификатор товара;
/// - `brandName`: название бренда;
/// - `title`: название товара;
/// - `price`: цена за единицу;
/// - `imageURL`: ссылка на изображение товара;
/// - `quantity`: количество товара в корзине;
/// - `updatedAt`: дата последнего изменения.
///
/// Особенности реализации:
/// - соответствует `snake_case` структуре таблицы Supabase;
/// - поддерживает `Codable` для прямого декодирования ответов;
/// - преобразуется в доменную модель `CartItem` через `toEntity()`.
struct CartDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let userId: String
    let productId: String
    let brandName: String
    let title: String
    let price: Double
    let imageURL: String?
    let quantity: Int
    let updatedAt: Date
    
    // MARK: - Mapping
    
    func toEntity() -> CartItem {
        CartItem(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: price,
            imageURL: imageURL,
            quantity: quantity,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CodingKeys

private extension CartDTO {
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case productId = "product_id"
        case brandName = "brand_name"
        case title
        case price
        case imageURL = "image_url"
        case quantity
        case updatedAt = "updated_at"
    }
}
