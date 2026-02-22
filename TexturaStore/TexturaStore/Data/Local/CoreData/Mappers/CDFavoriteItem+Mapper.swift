//
//  CDFavoriteItem+Mapper.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation

/// Расширение `CDFavoriteItem`, обеспечивающее маппинг между Core Data и DTO/Entity слоями.
///
/// Основные задачи:
/// - применение данных из `FavoriteDTO` к Core Data сущности (`apply(dto:)`);
/// - преобразование `CDFavoriteItem` в доменную модель `FavoriteItem`.
///
/// Используется в:
/// - `FavoritesLocalStore` и `FavoritesRepository` для сохранения и чтения данных избранных товаров.
extension CDFavoriteItem {
    
    /// Применяет данные из `FavoriteDTO` к Core Data сущности `CDFavoriteItem`.
    /// - Parameter dto: DTO объекта избранного, полученного с сервера или локального источника.
    func apply(dto: FavoriteDTO) {
        userId = dto.userId
        productId = dto.productId
        brandName = dto.brandName
        title = dto.title
        imageURL = dto.imageURL
        updatedAt = dto.updatedAt
        price = dto.price
    }
    
    /// Преобразует `CDFavoriteItem` в доменную модель `FavoriteItem`.
    /// Используется при реактивных обновлениях (`FRCPublisher`).
    func toFavoriteItem() -> FavoriteItem {
        FavoriteItem(
            userId: userId ?? "",
            productId: productId ?? "",
            brandName: brandName ?? "",
            title: title ?? "",
            price: price,
            imageURL: imageURL,
            updatedAt: updatedAt ?? Date()
        )
    }
}

/// Расширение `FavoriteItem`, предоставляющее инициализацию из Core Data сущности `CDFavoriteItem`.
///
/// Выполняет:
/// - безопасное извлечение и валидацию данных;
/// - маппинг Core Data модели в доменную структуру `FavoriteItem`.
extension FavoriteItem {
    
    /// Инициализирует доменную модель `FavoriteItem` из Core Data сущности.
    /// - Parameter cd: Объект `CDFavoriteItem` из Core Data.
    init?(cd: CDFavoriteItem?) {
        guard let cd,
              let userId = cd.userId,
              let productId = cd.productId,
              let brandName = cd.brandName,
              let title = cd.title,
              let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: cd.price,
            imageURL: cd.imageURL,
            updatedAt: updatedAt
        )
    }
}
