//
//  DefaultCartRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine

/// Класс `DefaultCartRepository` — реализация репозитория корзины.
///
/// Назначение:
/// - объединяет работу локального (`CartLocalStore`) и удалённого (`CartStoreProtocol`) источников данных;
/// - синхронизирует состояние корзины между Firestore и Core Data;
/// - предоставляет реактивные паблишеры для отслеживания содержимого корзины и её итоговых параметров.
///
/// Состав:
/// - `remote`: Firestore-источник данных (загрузка, изменение, удаление товаров);
/// - `local`: локальное Core Data-хранилище корзины;
/// - `catalog`: источник метаданных о товарах для корректного отображения и апдейтов;
/// - `userId`: идентификатор текущего пользователя;
/// - `itemsSubject`: Combine-паблишер для актуального состояния корзины.
///
/// Основные функции:
/// - `observeItems()` — возвращает поток товаров корзины пользователя в реальном времени;
/// - `observeTotals()` — вычисляет суммарное количество и цену корзины;
/// - `refresh(uid:)` — синхронизирует локальные данные с Firestore;
/// - `add(productId:by:)` — добавляет товар в корзину или увеличивает количество;
/// - `setQuantity(productId:quantity:)` — устанавливает конкретное количество товара;
/// - `remove(productId:)` — удаляет товар из корзины;
/// - `clear()` — очищает корзину пользователя.
///
/// Особенности реализации:
/// - использует Combine-потоки для двусторонней синхронизации (локаль ↔ Firestore);
/// - при изменениях в Firestore автоматически обновляет локальное хранилище;
/// - обеспечивает реактивную модель данных без ручного обновления UI;
/// - все операции записи выполняются асинхронно для повышения отзывчивости интерфейса.

final class DefaultCartRepository: CartRepository {
    
    // MARK: - Deps
    
    private let remote: CartStoreProtocol
    private let local: CartLocalStore
    private let catalog: CatalogLocalStore
    private let userId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private let itemsSubject = CurrentValueSubject<[CartItem], Never>([])
    
    // MARK: - Init
    
    init(remote: CartStoreProtocol,
         local: CartLocalStore,
         catalog: CatalogLocalStore,
         userId: String) {
        self.remote = remote
        self.local = local
        self.catalog = catalog
        self.userId = userId
        
        bindStreams()
    }
    
    // MARK: - Streams
    
    func observeItems() -> AnyPublisher<[CartItem], Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    
    func observeTotals() -> AnyPublisher<(count: Int, price: Double), Never> {
        observeItems()
            .map { items in
                let count = items.reduce(0) { $0 + $1.quantity }
                let price = items.reduce(0.0) { $0 + $1.lineTotal }
                return (count, price)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Commands
    
    func refresh(uid: String) async throws {
        let dtos = try await remote.fetchCart(uid: uid)
        local.replaceAll(userId: userId, with: dtos)
    }
    
    func add(productId: String, by delta: Int) async throws {
        guard delta != 0 else { return }
        guard let meta = catalog.meta(for: productId) else { return }
        
        let dto = CartDTO(
            userId: userId,
            productId: productId,
            brandName: meta.brandName,
            title: meta.title,
            price: meta.price,
            imageURL: meta.imageURL?.absoluteString,
            quantity: delta,
            updatedAt: Date()
        )
        
        // 1) Optimistic local update (UI/кэш сразу)
        local.upsert(userId: userId, dto: dto, accumulate: true)
        
        // 2) Remote update
        do {
            // dto.quantity для remote не критичен, т.к. там есть `by: delta`,
            // но оставляем текущую модель вызова.
            let remoteDTO = CartDTO(
                userId: userId,
                productId: productId,
                brandName: meta.brandName,
                title: meta.title,
                price: meta.price,
                imageURL: meta.imageURL?.absoluteString,
                quantity: max(1, delta),
                updatedAt: Date()
            )
            try await remote.addOrAccumulate(uid: userId, dto: remoteDTO, by: delta)
        } catch {
            // 3) Recovery: приводим локалку к истине
            try? await refresh(uid: userId)
            throw error
        }
    }
    
    func setQuantity(productId: String, quantity: Int) async throws {
        let clamped = max(0, quantity)
        
        let dto: CartDTO
        if let meta = catalog.meta(for: productId) {
            dto = CartDTO(
                userId: userId,
                productId: productId,
                brandName: meta.brandName,
                title: meta.title,
                price: meta.price,
                imageURL: meta.imageURL?.absoluteString,
                quantity: clamped,
                updatedAt: Date()
            )
        } else {
            dto = CartDTO(
                userId: userId,
                productId: productId,
                brandName: "",
                title: "",
                price: .zero,
                imageURL: nil,
                quantity: clamped,
                updatedAt: Date()
            )
        }
        
        // 1) Optimistic local update
        if clamped == 0 {
            local.remove(userId: userId, productId: productId)
        } else {
            // setQuantity в local не создаёт сущность, если её нет,
            // поэтому делаем upsert (без accumulate) — корректнее.
            local.upsert(userId: userId, dto: dto, accumulate: false)
        }
        
        // 2) Remote update
        do {
            try await remote.setQuantity(uid: userId, dto: dto, quantity: clamped)
        } catch {
            // 3) Recovery
            try? await refresh(uid: userId)
            throw error
        }
    }
    
    func remove(productId: String) async throws {
        // 1) Optimistic local update
        local.remove(userId: userId, productId: productId)
        
        // 2) Remote update
        do {
            try await remote.remove(uid: userId, productId: productId)
        } catch {
            // 3) Recovery
            try? await refresh(uid: userId)
            throw error
        }
    }
    
    func clear() async throws {
        // 1) Optimistic local update
        local.clear(userId: userId)
        
        // 2) Remote update
        do {
            try await remote.clear(uid: userId)
        } catch {
            // 3) Recovery
            try? await refresh(uid: userId)
            throw error
        }
    }
}

// MARK: - Private

private extension DefaultCartRepository {
    func bindStreams() {
        local.observeItems(userId: userId)
            .subscribe(itemsSubject)
            .store(in: &bag)
        
        remote.listenCart(uid: userId)
            .sink { [weak self] dtos in
                guard let self else { return }
                self.local.replaceAll(userId: self.userId, with: dtos)
            }
            .store(in: &bag)
    }
}
