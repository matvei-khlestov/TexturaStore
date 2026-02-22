//
//  ProductColorDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import Foundation

/// Data Transfer Object, описывающий цвет товара (`ProductColorDTO`) в слое данных.
///
/// Назначение:
/// - используется для получения и синхронизации цветов товаров из Supabase (PostgreSQL);
/// - изолирует сетевой формат таблицы от доменной модели `ProductColor`;
/// - применяется при загрузке и обновлении справочников каталога.
///
/// Состав:
/// - `id`: уникальный идентификатор цвета;
/// - `nameRu`, `nameEn`: наименования цвета на RU/EN;
/// - `hex`: HEX-код цвета (например, `#FFFFFF`);
/// - `isActive`: флаг активности цвета;
/// - `createdAt`, `updatedAt`: даты создания и последнего обновления записи.
///
/// Особенности реализации:
/// - соответствует `snake_case` структуре таблицы Supabase;
/// - поддерживает `Codable` для удобного декодирования;
/// - преобразуется в доменную модель `ProductColor` через `toEntity()`.
struct ProductColorDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let id: String
    let nameRu: String
    let nameEn: String
    let hex: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Mapping
    
    func toEntity() -> ProductColor {
        ProductColor(
            id: id,
            nameRu: nameRu,
            nameEn: nameEn,
            hex: hex,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CodingKeys

private extension ProductColorDTO {
    enum CodingKeys: String, CodingKey {
        case id
        case nameRu = "name_ru"
        case nameEn = "name_en"
        case hex
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
