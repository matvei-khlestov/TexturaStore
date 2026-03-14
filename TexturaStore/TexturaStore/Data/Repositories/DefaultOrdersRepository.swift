//
//  DefaultOrdersRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation
import Combine

/// Класс `DefaultOrdersRepository` — реализация репозитория заказов.
///
/// Назначение:
/// - объединяет работу удалённого источника (`OrdersStoreProtocol`, Supabase)
///   и локального (`OrdersLocalStore`, Core Data);
/// - обеспечивает синхронизацию заказов пользователя между Supabase и локальной базой;
/// - предоставляет реактивное наблюдение за заказами для UI через Combine.
///
/// Архитектурная роль:
/// - выступает посредником между слоем данных (Supabase + Core Data)
///   и слоем представления (`ViewModel`);
/// - инкапсулирует бизнес-логику синхронизации заказов;
/// - скрывает детали работы сетевого и локального хранилища.
///
/// Состав:
/// - `remote`: удалённый источник заказов (Supabase PostgREST + Realtime);
/// - `local`: локальное Core Data хранилище заказов для офлайн-доступа;
/// - `userId`: идентификатор текущего пользователя;
/// - `ordersSubject`: Combine-паблишер, транслирующий актуальный список заказов.
///
/// Поток данных:
/// 1. Supabase (`OrdersStoreProtocol`)
///    → получение, создание и обновление заказов.
/// 2. Core Data (`OrdersLocalStore`)
///    → локальный кэш и реактивное наблюдение.
/// 3. Repository
///    → синхронизирует данные и транслирует `OrderEntity` во ViewModel.
///
/// Основные функции:
/// - `observeOrders()` — реактивное наблюдение заказов через Combine;
/// - `refresh(uid:)` — синхронизация локального состояния с Supabase;
/// - `create(order:)` — создание нового заказа и обновление локального состояния;
/// - `updateStatus(orderId:to:)` — изменение статуса заказа локально и на сервере;
/// - `clear()` — очистка заказов пользователя локально и в Supabase.
///
/// Особенности реализации:
/// - использует Supabase PostgREST для CRUD-операций над заказами;
/// - использует Supabase Realtime для отслеживания изменений заказов;
/// - хранит локальный кэш заказов в Core Data;
/// - синхронизирует локальное состояние через Combine.
///
/// Дополнительно:
/// - содержит вспомогательный метод `createOrderFromCheckout()`
///   для формирования заказа из данных экрана Checkout.

final class DefaultOrdersRepository: OrdersRepository {
    
    // MARK: - Deps
    
    private let remote: OrdersStoreProtocol
    private let local: OrdersLocalStore
    private let userId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private let ordersSubject = CurrentValueSubject<[OrderEntity], Never>([])
    
    // MARK: - Init
    
    init(remote: OrdersStoreProtocol,
         local: OrdersLocalStore,
         userId: String) {
        self.remote = remote
        self.local = local
        self.userId = userId
        bindStreams()
    }
    
    // MARK: - Streams
    
    func observeOrders() -> AnyPublisher<[OrderEntity], Never> {
        ordersSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Commands
    
    func refresh(uid: String) async throws {
        let dtos = try await remote.fetchOrders(uid: uid)
        local.replaceAll(userId: userId, with: dtos)
    }
    
    func create(order: OrderDTO) async throws {
        try await remote.createOrder(uid: userId, dto: order)
        local.upsert(userId: userId, dto: order)
    }
    
    func updateStatus(orderId: String, to status: OrderStatus) async throws {
        try await remote.updateStatus(
            uid: userId,
            orderId: orderId,
            status: status
        )
        local.updateStatus(
            userId: userId,
            orderId: orderId,
            status: status
        )
    }
    
    func clear() async throws {
        try await remote.clear(uid: userId)
        local.clear(userId: userId)
    }
}

// MARK: - Private

private extension DefaultOrdersRepository {
    func bindStreams() {
        local.observeOrders(userId: userId)
            .subscribe(ordersSubject)
            .store(in: &bag)
        
        remote.listenOrders(uid: userId)
            .sink { [weak self] dtos in
                guard let self else { return }
                self.local.replaceAll(userId: self.userId, with: dtos)
            }
            .store(in: &bag)
    }
}

extension OrdersRepository {
    @discardableResult
    func createOrderFromCheckout(
        userId: String,
        items: [CartItem],
        deliveryMethod: CheckoutViewModel.DeliveryMethod,
        addressString: String?,
        phoneE164: String?,
        comment: String?
    ) async throws -> String {
        let receiveAddress: String = {
            switch deliveryMethod {
            case .pickup:   return "Пункт самовывоза"
            case .delivery: return addressString ?? ""
            }
        }()
        
        let orderItems = items.map {
            OrderItemDTO(
                productId: $0.productId,
                brandName: $0.brandName,
                title:     $0.title,
                price:     $0.price,
                imageURL:  $0.imageURL,
                quantity:  $0.quantity
            )
        }
        
        let now = Date()
        let id = UUID().uuidString
        let dto = OrderDTO(
            id: id,
            userId: userId,
            createdAt: now,
            updatedAt: now,
            status: .assembling,
            receiveAddress: receiveAddress,
            paymentMethod: "При получении",
            comment: comment,
            phoneE164: phoneE164,
            items: orderItems
        )
        
        try await create(order: dto)
        return id
    }
}
