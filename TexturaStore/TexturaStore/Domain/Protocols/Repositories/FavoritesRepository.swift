//
//  FavoritesRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine

/// Протокол `FavoritesRepository`
///
/// Определяет единый интерфейс управления **избранными товарами пользователя**,
/// объединяя локальный слой (`FavoritesLocalStore`, Core Data)
/// и удалённый слой (`FavoritesStoreProtocol`, Supabase).
///
/// Назначение:
/// - предоставляет реактивное состояние избранного для UI (через Combine);
/// - синхронизирует локальное хранилище с Supabase;
/// - инкапсулирует бизнес-логику добавления, удаления и переключения избранного.
///
/// Контекст Supabase:
/// - данные избранного хранятся в PostgreSQL (например, таблица `favorite_items`);
/// - операции чтения/записи выполняются через PostgREST;
/// - realtime-обновления получаются через Supabase Realtime (Postgres Changes);
/// - доступ пользователя к данным ограничен RLS-политиками по `user_id`;
/// - уникальность избранного товара обеспечивается парой (`user_id`, `product_id`).
///
/// Архитектурная роль:
/// - **UI всегда читает данные только из локального слоя** (Core Data);
/// - Supabase используется как источник истины и механизм синхронизации;
/// - изменения с сервера автоматически отражаются в локальном состоянии.
///
/// Используется в:
/// - `FavoritesViewModel` для отображения списка избранных товаров;
/// - `ProductDetailsViewModel` для управления состоянием «в избранном»;
/// - глобальных UI-компонентах (иконки, бейджи, quick-actions).
///
/// Репозиторий скрывает детали:
/// - сетевых запросов Supabase;
/// - политики конфликтов и повторных апдейтов;
/// - механизма realtime-подписок,
/// предоставляя чистый и устойчивый API для слоя Presentation.

protocol FavoritesRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за всеми избранными товарами пользователя.
    /// - Returns: Паблишер, эмитирующий массив `FavoriteItem`.
    func observeItems() -> AnyPublisher<[FavoriteItem], Never>
    
    /// Наблюдает за идентификаторами избранных товаров.
    /// - Returns: Паблишер, эмитирующий множество `Set<String>` (ID товаров).
    func observeIds() -> AnyPublisher<Set<String>, Never>

    // MARK: - Commands
    
    /// Обновляет локальное состояние, синхронизируя избранное с сервером.
    /// - Parameter uid: Идентификатор пользователя.
    func refresh(uid: String) async throws
    
    /// Добавляет товар в избранное.
    /// - Parameter productId: Идентификатор товара.
    func add(productId: String) async throws
    
    /// Удаляет товар из избранного.
    /// - Parameter productId: Идентификатор товара.
    func remove(productId: String) async throws
    
    /// Переключает состояние избранного (добавляет или удаляет).
    /// - Parameter productId: Идентификатор товара.
    func toggle(productId: String) async throws
    
    /// Полностью очищает избранное (например, при выходе пользователя).
    func clear() async throws
}
