//
//  CDCategory+Mapper.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import CoreData

/// Расширение `CDCategory`, реализующее маппинг между Core Data и Domain слоями.
///
/// Назначение:
/// - применяет данные из `CategoryDTO` к локальной сущности `CDCategory`;
/// - предоставляет сравнение `matches(_:)` для предотвращения лишних обновлений;
/// - используется как часть локального кеша каталога.
///
/// Используется в:
/// - `CoreDataCatalogStore`;
/// - `DefaultCatalogRepository`.
extension CDCategory {
    
    /// Применяет данные из `CategoryDTO` к Core Data сущности `CDCategory`.
    /// - Parameter dto: DTO категории, полученный из Supabase.
    func apply(dto: CategoryDTO) {
        id = dto.id
        nameRu = dto.nameRu
        nameEn = dto.nameEn
        imageURL = dto.imageURL
        isActive = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение всех полей сущности с переданным DTO.
    /// Используется для предотвращения избыточных обновлений Core Data.
    /// - Parameter dto: DTO категории.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: CategoryDTO) -> Bool {
        (id ?? "") == dto.id
        && (nameRu ?? "") == dto.nameRu
        && (nameEn ?? "") == dto.nameEn
        && (imageURL ?? "") == dto.imageURL
        && isActive == dto.isActive
        && (createdAt ?? .distantPast) == dto.createdAt
        && (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `Category`, предоставляющее инициализацию
/// доменной модели на основе Core Data сущности `CDCategory`.
///
/// Выполняет безопасное извлечение данных и создание доменной модели
/// без преобразования дат (Domain использует `Date`).
extension Category {
    
    /// Инициализирует доменную модель `Category` из Core Data сущности `CDCategory`.
    /// - Parameter cd: Core Data объект `CDCategory`.
    init?(cd: CDCategory?) {
        guard
            let cd,
            let id = cd.id,
            let nameRu = cd.nameRu,
            let nameEn = cd.nameEn,
            let imageURL = cd.imageURL,
            let createdAt = cd.createdAt,
            let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            nameRu: nameRu,
            nameEn: nameEn,
            imageURL: imageURL,
            isActive: cd.isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
