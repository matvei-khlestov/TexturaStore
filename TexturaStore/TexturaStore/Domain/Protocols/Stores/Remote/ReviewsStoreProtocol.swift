//
//  ReviewsStoreProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Combine

/// Протокол `ReviewsStoreProtocol`
///
/// Определяет интерфейс удалённого слоя хранения отзывов товаров.
///
/// Назначение:
/// - обеспечивает работу с отзывами через Supabase (PostgREST + Realtime);
/// - инкапсулирует сетевые операции CRUD над таблицей отзывов;
/// - предоставляет реактивный поток изменений для синхронизации UI.
///
/// Контекст Supabase:
/// - данные отзывов хранятся в PostgreSQL (таблица `product_reviews`);
/// - чтение и запись выполняются через PostgREST (`select`, `insert`, `update`, `delete`);
/// - realtime-обновления реализуются через Supabase Realtime (Postgres Changes);
/// - доступ пользователя ограничивается RLS-политиками по `user_id`.
///
/// Используется в:
/// - `SupabaseReviewsStore` как конкретная реализация;
/// - `ReviewsRepository` для объединения удалённого и локального слоёв;
/// - ViewModel отзывов для отображения списка отзывов.
protocol ReviewsStoreProtocol: AnyObject {
    
    /// Загружает отзывы товара.
    /// - Parameter productId: Идентификатор товара.
    /// - Returns: Массив `ProductReviewDTO`.
    func fetch(productId: String) async throws -> [ProductReviewDTO]
    
    /// Добавляет отзыв.
    /// - Parameter dto: DTO создаваемого отзыва.
    func add(dto: ProductReviewDTO) async throws
    
    /// Обновляет отзыв пользователя.
    /// - Parameter dto: DTO обновляемого отзыва.
    func update(dto: ProductReviewDTO) async throws
    
    /// Удаляет отзыв пользователя.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - reviewId: Идентификатор отзыва.
    func remove(uid: String, reviewId: String) async throws
    
    /// Реактивно слушает изменения отзывов товара.
    /// - Parameter productId: Идентификатор товара.
    /// - Returns: Паблишер массива `ProductReviewDTO`.
    func listen(productId: String) -> AnyPublisher<[ProductReviewDTO], Never>
}
