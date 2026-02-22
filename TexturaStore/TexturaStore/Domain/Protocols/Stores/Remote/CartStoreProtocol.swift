//
//  CartStoreProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine

/// Протокол `CartStoreProtocol`
///
/// Определяет интерфейс удалённого слоя хранения корзины пользователя.
///
/// Назначение:
/// - обеспечивает работу с корзиной через Supabase (PostgREST + Realtime);
/// - инкапсулирует сетевые операции CRUD над элементами корзины;
/// - предоставляет реактивный поток изменений корзины для синхронизации с локальным состоянием и UI.
///
/// Контекст Supabase:
/// - данные корзины хранятся в PostgreSQL (таблица, например, `cart_items`);
/// - чтение и запись выполняются через PostgREST (`select`, `insert`, `update`, `delete`, `upsert`);
/// - realtime-обновления реализуются через Supabase Realtime (Postgres Changes);
/// - доступ к данным пользователя ограничивается RLS-политиками по `user_id`.
///
/// Используется в:
/// - `SupabaseCartStore` как конкретная реализация протокола;
/// - `CartRepository` для объединения удалённого и локального слоёв;
/// - ViewModel корзины для управления состоянием и отображением.
///
/// Протокол намеренно не содержит деталей реализации (RPC, транзакции),
/// оставляя их на стороне конкретного Supabase-хранилища.

protocol CartStoreProtocol: AnyObject {
    
    /// Загружает текущее содержимое корзины пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Список товаров в корзине в формате `CartDTO`.
    func fetchCart(uid: String) async throws -> [CartDTO]
    
    /// Устанавливает новое количество товара в корзине.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - dto: DTO товара.
    ///   - quantity: Новое количество.
    func setQuantity(uid: String, dto: CartDTO, quantity: Int) async throws
    
    /// Добавляет товар или увеличивает его количество в корзине.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - dto: DTO добавляемого товара.
    ///   - delta: Изменение количества (может быть отрицательным).
    func addOrAccumulate(uid: String, dto: CartDTO, by delta: Int) async throws
    
    /// Удаляет товар из корзины по его идентификатору.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - productId: Идентификатор удаляемого товара.
    func remove(uid: String, productId: String) async throws
    
    /// Полностью очищает корзину пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    func clear(uid: String) async throws
    
    /// Реактивно слушает изменения содержимого корзины пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Паблишер, эмитирующий актуальный список `CartDTO`.
    func listenCart(uid: String) -> AnyPublisher<[CartDTO], Never>
}
