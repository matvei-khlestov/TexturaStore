//
//  OrdersRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Combine

/// Протокол `OrdersRepository`
///
/// Репозиторий заказов, объединяющий удалённое хранилище Supabase
/// (`OrdersStoreProtocol`) и локальное Core Data хранилище (`OrdersLocalStore`).
///
/// Назначение:
/// - предоставляет единый интерфейс доступа к заказам пользователя;
/// - синхронизирует данные между Supabase и локальной базой;
/// - обеспечивает реактивное обновление UI через Combine;
/// - инкапсулирует бизнес-логику создания и обновления заказов.
///
/// Архитектурная роль:
/// - слой Domain/Data boundary;
/// - изолирует ViewModel от деталей работы с Supabase и Core Data;
/// - выполняет orchestration между удалённым и локальным источниками.
///
/// Поток данных:
/// 1. Supabase (`OrdersStoreProtocol`)
///    → загрузка/создание/обновление заказов.
/// 2. Core Data (`OrdersLocalStore`)
///    → локальный кэш и реактивное наблюдение.
/// 3. Repository
///    → синхронизирует оба источника и отдаёт `OrderEntity` во ViewModel.
///
/// Используется в:
/// - `OrdersViewModel` — отображение истории заказов;
/// - `CheckoutViewModel` — создание заказа после оформления покупки.
///
/// Особенности реализации:
/// - сетевые операции выполняются через Supabase (PostgREST);
/// - локальное состояние хранится в Core Data;
/// - обновления заказов транслируются через Combine;
/// - синхронизация выполняется методом `refresh(uid:)`.

protocol OrdersRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за локальными изменениями списка заказов.
    /// - Returns: Паблишер, эмитирующий массив сущностей `OrderEntity`.
    func observeOrders() -> AnyPublisher<[OrderEntity], Never>
    
    // MARK: - Commands
    
    /// Обновляет локальные данные заказов, синхронизируя их с удалённым хранилищем.
    /// - Parameter uid: Идентификатор пользователя.
    func refresh(uid: String) async throws
    
    /// Создаёт новый заказ в удалённом хранилище.
    /// - Parameter order: DTO заказа для создания.
    func create(order: OrderDTO) async throws
    
    /// Обновляет статус конкретного заказа.
    /// - Parameters:
    ///   - orderId: Идентификатор заказа.
    ///   - status: Новый статус.
    func updateStatus(orderId: String, to status: OrderStatus) async throws
    
    /// Полностью очищает локальное состояние заказов (например, при выходе из профиля).
    func clear() async throws
    
    // MARK: - Checkout
    
    /// Создаёт заказ из данных Checkout.
    /// Важно: это требование протокола, чтобы в тестах спай мог перехватывать вызов.
    func createOrderFromCheckout(
        userId: String,
        items: [CartItem],
        deliveryMethod: CheckoutViewModel.DeliveryMethod,
        addressString: String?,
        phoneE164: String?,
        comment: String?
    ) async throws -> String
}
