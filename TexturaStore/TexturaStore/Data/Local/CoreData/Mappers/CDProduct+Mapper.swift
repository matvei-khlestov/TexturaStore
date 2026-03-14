//
//  CDProduct+Mapper.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import CoreData

/// Расширение `CDProduct`, реализующее маппинг между Core Data и Domain слоями.
///
/// Назначение:
/// - применяет данные из `ProductDTO` к сущности Core Data `CDProduct` (локальный кеш каталога);
/// - предоставляет сравнение `matches(_:)` для предотвращения избыточных обновлений;
/// - позволяет собрать доменную модель `Product` из `CDProduct`.
///
/// Используется в:
/// - `CoreDataCatalogStore` (локальное хранилище / кеш);
/// - `DefaultCatalogRepository` (синхронизация каталога Supabase ↔︎ Core Data).
extension CDProduct {
    
    /// Применяет данные из `ProductDTO` к Core Data сущности `CDProduct`.
    /// - Parameter dto: DTO товара, полученный из Supabase.
    func apply(dto: ProductDTO) {
        id = dto.id
        categoryId = dto.categoryId
        brandId = dto.brandId
        colorId = dto.colorId
        price = dto.price
        imageURL = dto.imageURL
        
        nameRu = dto.nameRu
        nameEn = dto.nameEn
        descriptionRu = dto.descriptionRu
        descriptionEn = dto.descriptionEn
        nameLowerRu = dto.nameLowerRu
        nameLowerEn = dto.nameLowerEn
        
        ratingAvg = dto.ratingAvg
        ratingCount = Int32(dto.ratingCount)
        isActive = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение полей сущности с переданным DTO.
    /// Используется для предотвращения избыточных обновлений.
    /// - Parameter dto: DTO для сравнения.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: ProductDTO) -> Bool {
        (id ?? "") == dto.id
        && (categoryId ?? "") == dto.categoryId
        && (brandId ?? "") == dto.brandId
        && (colorId ?? "") == dto.colorId
        && price == dto.price
        && (imageURL ?? "") == dto.imageURL
        && (nameRu ?? "") == dto.nameRu
        && (nameEn ?? "") == dto.nameEn
        && (descriptionRu ?? "") == dto.descriptionRu
        && (descriptionEn ?? "") == dto.descriptionEn
        && (nameLowerRu ?? "") == dto.nameLowerRu
        && (nameLowerEn ?? "") == dto.nameLowerEn
        && ratingAvg == dto.ratingAvg
        && ratingCount == Int32(dto.ratingCount)
        && isActive == dto.isActive
        && (createdAt ?? .distantPast) == dto.createdAt
        && (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `Product`, предоставляющее инициализацию
/// доменной модели на основе Core Data сущности `CDProduct`.
///
/// Выполняет безопасное извлечение данных и создание `Product`
/// с сохранением типов дат (`Date`) в Domain-слое.
extension Product {
    
    /// Инициализирует доменную модель `Product` из Core Data сущности `CDProduct`.
    /// - Parameter cd: Core Data объект `CDProduct`.
    init?(cd: CDProduct?) {
        guard
            let cd,
            let id = cd.id,
            let categoryId = cd.categoryId,
            let brandId = cd.brandId,
            let colorId = cd.colorId,
            let imageURL = cd.imageURL,
            let nameRu = cd.nameRu,
            let nameEn = cd.nameEn,
            let descriptionRu = cd.descriptionRu,
            let descriptionEn = cd.descriptionEn,
            let nameLowerRu = cd.nameLowerRu,
            let nameLowerEn = cd.nameLowerEn,
            let createdAt = cd.createdAt,
            let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            categoryId: categoryId,
            brandId: brandId,
            colorId: colorId,
            price: cd.price,
            imageURL: imageURL,
            nameRu: nameRu,
            nameEn: nameEn,
            descriptionRu: descriptionRu,
            descriptionEn: descriptionEn,
            nameLowerRu: nameLowerRu,
            nameLowerEn: nameLowerEn,
            ratingAvg: cd.ratingAvg,
            ratingCount: Int(cd.ratingCount),
            isActive: cd.isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
