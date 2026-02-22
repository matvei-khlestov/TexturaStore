//
//  BrandDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import Foundation

/// Data Transfer Object, описывающий бренд (`BrandDTO`) в слое данных.
///
/// Назначение:
/// - используется для получения и синхронизации данных брендов из Supabase (PostgreSQL / Storage);
/// - изолирует сетевой формат таблицы от доменной модели `Brand`;
/// - применяется при загрузке и обновлении каталога.
///
/// Состав:
/// - `id`: уникальный идентификатор бренда;
/// - `name`: наименование бренда;
/// - `imageURL`: публичная ссылка на изображение бренда (Supabase Storage);
/// - `isActive`: флаг активности бренда (участвует в фильтрации каталога);
/// - `createdAt`, `updatedAt`: даты создания и последнего обновления записи.
///
/// Особенности реализации:
/// - соответствует `snake_case` структуре таблицы Supabase;
/// - поддерживает `Codable` для прямого декодирования ответов;
/// - преобразуется в доменную модель `Brand` через `toEntity()`.
struct BrandDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let id: String
    let name: String
    let imageURL: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Mapping
    
    func toEntity() -> Brand {
        Brand(
            id: id,
            name: name,
            imageURL: imageURL,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CodingKeys

private extension BrandDTO {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
