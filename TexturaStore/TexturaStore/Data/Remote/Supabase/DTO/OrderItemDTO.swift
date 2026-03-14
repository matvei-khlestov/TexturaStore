//
//  OrderItemDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation

/// Data Transfer Object, описывающий позицию заказа (`OrderItemDTO`) в слое данных.
///
/// Назначение:
/// - используется для передачи данных позиции заказа между слоями Data и Domain;
/// - изолирует формат хранения позиции заказа от доменной модели `OrderItem`;
/// - содержит минимальный набор данных товара, необходимый для отображения заказа.
///
/// Состав:
/// - `productId`: идентификатор товара;
/// - `brandName`: название бренда товара;
/// - `title`: название товара;
/// - `price`: цена товара на момент покупки;
/// - `imageURL`: ссылка на изображение товара;
/// - `quantity`: количество товара в заказе.
///
/// Особенности реализации:
/// - поддерживает `Codable` для декодирования JSON;
/// - используется внутри `OrderDTO`;
/// - преобразуется в `OrderItem` через `toEntity()`.
struct OrderItemDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let productId: String
    let brandName: String
    let title: String
    let price: Double
    let imageURL: String?
    let quantity: Int
    
    // MARK: - Mapping
    
    func toEntity(createdAt: Date, updatedAt: Date) -> OrderItem {
        OrderItem(
            product: Product(
                id: productId,
                categoryId: "",
                brandId: brandName,
                colorId: "",
                price: price,
                imageURL: imageURL ?? "",
                nameRu: title,
                nameEn: title,
                descriptionRu: "",
                descriptionEn: "",
                nameLowerRu: title.lowercased(),
                nameLowerEn: title.lowercased(),
                ratingAvg: 0,
                ratingCount: 0,
                isActive: true,
                createdAt: createdAt,
                updatedAt: updatedAt
            ),
            quantity: quantity
        )
    }
}

// MARK: - CodingKeys

private extension OrderItemDTO {
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case brandName = "brand_name"
        case title
        case price
        case imageURL = "image_url"
        case quantity
    }
}
