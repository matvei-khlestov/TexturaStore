//
//  CDProductColor+Mapper.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import CoreData

/// Расширение `CDProductColor`, реализующее маппинг между Core Data и Domain слоями.
///
/// Назначение:
/// - применяет данные из `ProductColorDTO` к локальной сущности `CDProductColor`;
/// - предоставляет сравнение `matches(_:)` для предотвращения лишних обновлений;
/// - обеспечивает создание доменной модели `ProductColor` из Core Data сущности.
///
/// Используется в:
/// - `CoreDataCatalogStore`;
/// - `DefaultCatalogRepository`.
extension CDProductColor {
    
    /// Применяет данные из `ProductColorDTO` к Core Data сущности `CDProductColor`.
    /// - Parameter dto: DTO цвета товара, полученный из Supabase.
    func apply(dto: ProductColorDTO) {
        id = dto.id
        nameRu = dto.nameRu
        nameEn = dto.nameEn
        hex = dto.hex
        isActive = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение всех полей сущности с переданным DTO.
    /// Используется для предотвращения избыточных обновлений Core Data.
    /// - Parameter dto: DTO цвета товара.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: ProductColorDTO) -> Bool {
        (id ?? "") == dto.id
        && (nameRu ?? "") == dto.nameRu
        && (nameEn ?? "") == dto.nameEn
        && (hex ?? "") == dto.hex
        && isActive == dto.isActive
        && (createdAt ?? .distantPast) == dto.createdAt
        && (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `ProductColor`, предоставляющее инициализацию доменной модели
/// на основе Core Data сущности `CDProductColor`.
///
/// Выполняет безопасное извлечение данных и создание доменной модели
/// без преобразования дат (Domain использует `Date`).
extension ProductColor {
    
    /// Инициализирует доменную модель `ProductColor` из Core Data сущности `CDProductColor`.
    /// - Parameter cd: Core Data объект `CDProductColor`.
    init?(cd: CDProductColor?) {
        guard
            let cd,
            let id = cd.id,
            let nameRu = cd.nameRu,
            let nameEn = cd.nameEn,
            let hex = cd.hex,
            let createdAt = cd.createdAt,
            let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            nameRu: nameRu,
            nameEn: nameEn,
            hex: hex,
            isActive: cd.isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
