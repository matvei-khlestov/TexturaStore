//
//  FavoriteDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation

/// Data Transfer Object, описывающий элемент избранного (`FavoriteDTO`) пользователя.
///
/// Назначение:
/// - используется для обмена данными между Supabase (PostgREST/Realtime) и локальным хранилищем (Core Data);
/// - изолирует сетевой формат таблицы Postgres от доменной модели `FavoriteItem` и UI;
/// - обеспечивает синхронизацию и кэширование состояния избранного пользователя.
///
/// Контекст Supabase:
/// - данные избранного хранятся в PostgreSQL (таблица, например, `favorite_items`);
/// - чтение/запись выполняются через PostgREST (`select`, `insert`, `update`, `delete`, `upsert`);
/// - realtime-обновления доступны через Supabase Realtime (Postgres Changes);
/// - доступ пользователя к своим данным ограничивается RLS-политиками по `user_id`;
/// - уникальность позиции обычно обеспечивается парой (`user_id`, `product_id`).
///
/// Состав:
/// - `userId`: идентификатор пользователя (владелец избранного);
/// - `productId`: идентификатор товара;
/// - `brandName`: название бренда (денормализовано для быстрого отображения списка);
/// - `title`: название товара (денормализовано для UI);
/// - `price`: цена товара (денормализовано для отображения и оффлайн-кэша);
/// - `imageURL`: ссылка на изображение товара (может быть пустой/отсутствовать в зависимости от схемы);
/// - `updatedAt`: дата последнего обновления записи.
///
/// Особенности реализации:
/// - `Codable` позволяет напрямую декодировать/энкодить JSON Supabase;
/// - `CodingKeys` (snake_case) сопоставляет свойства DTO со столбцами таблицы;
/// - `toEntity()` преобразует DTO в доменную модель `FavoriteItem`;
/// - используется в `SupabaseFavoritesStore` (удалённый слой) и `CoreDataFavoritesStore` (локальный слой).
struct FavoriteDTO: Codable, Equatable {
    let userId: String
    let productId: String
    let brandName: String
    let title: String
    let imageURL: String?
    let updatedAt: Date
    let price: Double
}

extension FavoriteDTO {
    func toEntity() -> FavoriteItem {
        .init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: price,
            imageURL: imageURL,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CodingKeys

private extension FavoriteDTO {
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case productId = "product_id"
        case brandName = "brand_name"
        case title
        case imageURL = "image_url"
        case updatedAt = "updated_at"
        case price
    }
}
