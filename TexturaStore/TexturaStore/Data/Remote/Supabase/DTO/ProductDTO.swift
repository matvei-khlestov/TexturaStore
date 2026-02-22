//
//  ProductDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import Foundation

/// Data Transfer Object, описывающий товар (`ProductDTO`) в слое данных.
///
/// Назначение:
/// - используется для получения и передачи данных из Supabase (PostgreSQL/Storage);
/// - изолирует сетевой формат от доменной модели `Product`;
/// - участвует в синхронизации каталога.
///
/// Состав:
/// - `id`: уникальный идентификатор товара;
/// - `categoryId`: идентификатор категории;
/// - `brandId`: идентификатор бренда;
/// - `colorId`: идентификатор цвета;
/// - `price`: цена товара;
/// - `imageURL`: ссылка на изображение товара (Storage/Public URL);
/// - `nameRu`, `nameEn`: названия товара на RU/EN;
/// - `descriptionRu`, `descriptionEn`: описания на RU/EN;
/// - `nameLowerRu`, `nameLowerEn`: значения для поиска (lowercased);
/// - `ratingAvg`, `ratingCount`: агрегированные данные рейтинга;
/// - `isActive`: флаг активности товара;
/// - `createdAt`, `updatedAt`: даты создания/обновления записи.
///
/// Особенности реализации:
/// - поддерживает `Codable` для декодирования ответов Supabase;
/// - ключи соответствуют `snake_case` полям таблицы;
/// - преобразуется в доменную модель через `toEntity()`.
struct ProductDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let id: String
    let categoryId: String
    let brandId: String
    let colorId: String
    let price: Double
    let imageURL: String
    let nameRu: String
    let nameEn: String
    let descriptionRu: String
    let descriptionEn: String
    let nameLowerRu: String
    let nameLowerEn: String
    let ratingAvg: Double
    let ratingCount: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Mapping
    
    func toEntity() -> Product {
        Product(
            id: id,
            categoryId: categoryId,
            brandId: brandId,
            colorId: colorId,
            price: price,
            imageURL: imageURL,
            nameRu: nameRu,
            nameEn: nameEn,
            descriptionRu: descriptionRu,
            descriptionEn: descriptionEn,
            nameLowerRu: nameLowerRu,
            nameLowerEn: nameLowerEn,
            ratingAvg: ratingAvg,
            ratingCount: ratingCount,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CodingKeys

private extension ProductDTO {
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case brandId = "brand_id"
        case colorId = "color_id"
        case price
        case imageURL = "image_url"
        case nameRu = "name_ru"
        case nameEn = "name_en"
        case descriptionRu = "description_ru"
        case descriptionEn = "description_en"
        case nameLowerRu = "name_lower_ru"
        case nameLowerEn = "name_lower_en"
        case ratingAvg = "rating_avg"
        case ratingCount = "rating_count"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
