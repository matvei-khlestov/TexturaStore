//
//  FavoritesStoreProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Combine

/// Протокол `FavoritesStoreProtocol`
///
/// Определяет интерфейс удалённого слоя хранения избранных товаров пользователя.
///
/// Назначение:
/// - обеспечивает работу с избранным через Supabase (PostgREST + Realtime);
/// - инкапсулирует сетевые операции CRUD над таблицей избранного;
/// - предоставляет реактивный поток изменений для синхронизации локального состояния и UI.
///
/// Контекст Supabase:
/// - данные избранного хранятся в PostgreSQL (таблица, например, `favorite_items`);
/// - чтение и запись выполняются через PostgREST (`select`, `insert`, `delete`, `upsert`);
/// - realtime-обновления реализуются через Supabase Realtime (Postgres Changes);
/// - доступ пользователя к своим данным ограничивается RLS-политиками по `user_id`;
/// - уникальность записи обычно обеспечивается составным ключом (`user_id`, `product_id`).
///
/// Используется в:
/// - `SupabaseFavoritesStore` как конкретная реализация протокола;
/// - `FavoritesRepository` для объединения удалённого и локального (Core Data) слоёв;
/// - ViewModel избранного для управления состоянием списка и синхронизации с сервером.
///
/// Протокол намеренно абстрагирует детали реализации (RPC, транзакции, onConflict),
/// оставляя их на стороне конкретного Supabase-хранилища.

protocol FavoritesStoreProtocol: AnyObject {
    
    /// Загружает список избранных товаров пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Массив моделей `FavoriteDTO`.
    func fetch(uid: String) async throws -> [FavoriteDTO]
    
    /// Добавляет товар в избранное.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - dto: DTO добавляемого избранного товара.
    func add(uid: String, dto: FavoriteDTO) async throws
    
    /// Удаляет товар из избранного.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - productId: Идентификатор товара.
    func remove(uid: String, productId: String) async throws
    
    /// Полностью очищает список избранных товаров пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    func clear(uid: String) async throws
    
    /// Реактивно слушает изменения в коллекции избранного.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Паблишер, эмитирующий актуальный список `FavoriteDTO`.
    func listen(uid: String) -> AnyPublisher<[FavoriteDTO], Never>
}
