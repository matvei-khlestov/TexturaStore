//
//  CategoryDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import Foundation

/// Data Transfer Object, описывающий категорию товаров (`CategoryDTO`) в слое данных.
///
/// Назначение:
/// - используется для получения и синхронизации данных категорий из Supabase (PostgreSQL / Storage);
/// - изолирует сетевой формат таблицы от доменной модели `Category`;
/// - применяется при загрузке и обновлении каталога.
///
/// Состав:
/// - `id`: уникальный идентификатор категории;
/// - `nameRu`, `nameEn`: названия категории на RU/EN;
/// - `imageURL`: публичная ссылка на изображение категории (Supabase Storage);
/// - `isActive`: флаг активности категории (участвует в фильтрации каталога);
/// - `createdAt`, `updatedAt`: даты создания и последнего обновления записи.
///
/// Особенности реализации:
/// - соответствует `snake_case` структуре таблицы Supabase;
/// - поддерживает `Codable` для декодирования ответов;
/// - преобразуется в доменную модель `Category` через `toEntity()`.
struct CategoryDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let id: String
    let nameRu: String
    let nameEn: String
    let imageURL: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Mapping
    
    func toEntity() -> Category {
        Category(
            id: id,
            nameRu: nameRu,
            nameEn: nameEn,
            imageURL: imageURL,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CodingKeys

private extension CategoryDTO {
    enum CodingKeys: String, CodingKey {
        case id
        case nameRu = "name_ru"
        case nameEn = "name_en"
        case imageURL = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
