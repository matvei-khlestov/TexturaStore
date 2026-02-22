//
//  CDBrand+Mapper.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import CoreData

/// Расширение `CDBrand`, реализующее маппинг между Core Data и Domain слоями.
///
/// Назначение:
/// - применяет данные из `BrandDTO` к локальной сущности `CDBrand`;
/// - предоставляет сравнение `matches(_:)` для предотвращения лишних обновлений;
/// - обеспечивает создание доменной модели `Brand` из Core Data сущности.
///
/// Используется в:
/// - `CoreDataCatalogStore`;
/// - `DefaultCatalogRepository`.
extension CDBrand {
    
    /// Применяет данные из `BrandDTO` к Core Data сущности `CDBrand`.
    /// - Parameter dto: DTO бренда, полученный из Supabase.
    func apply(dto: BrandDTO) {
        id = dto.id
        name = dto.name
        imageURL = dto.imageURL
        isActive = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение всех полей сущности с переданным DTO.
    /// Используется для предотвращения избыточных обновлений Core Data.
    /// - Parameter dto: DTO бренда.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: BrandDTO) -> Bool {
        (id ?? "") == dto.id
        && (name ?? "") == dto.name
        && (imageURL ?? "") == dto.imageURL
        && isActive == dto.isActive
        && (createdAt ?? .distantPast) == dto.createdAt
        && (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `Brand`, предоставляющее инициализацию доменной модели
/// на основе Core Data сущности `CDBrand`.
///
/// Выполняет безопасное извлечение данных и создание доменной модели
/// без преобразования дат (Domain использует `Date`).
extension Brand {
    
    /// Инициализирует доменную модель `Brand` из Core Data сущности `CDBrand`.
    /// - Parameter cd: Core Data объект `CDBrand`.
    init?(cd: CDBrand?) {
        guard
            let cd,
            let id = cd.id,
            let name = cd.name,
            let imageURL = cd.imageURL,
            let createdAt = cd.createdAt,
            let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            name: name,
            imageURL: imageURL,
            isActive: cd.isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
