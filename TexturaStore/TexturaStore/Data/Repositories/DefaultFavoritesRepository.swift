//
//  DefaultFavoritesRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine

/// Класс `DefaultFavoritesRepository` — реализация репозитория избранного.
///
/// Назначение:
/// - объединяет работу локального (`FavoritesLocalStore`, Core Data)
///   и удалённого (`FavoritesStoreProtocol`, Supabase) источников данных;
/// - синхронизирует список избранных товаров между Supabase (PostgreSQL)
///   и локальным кэшем Core Data;
/// - предоставляет реактивное состояние избранного для UI через Combine.
///
/// Контекст Supabase:
/// - данные избранного хранятся в таблице `favorite_items`;
/// - чтение и запись выполняются через PostgREST (`select`, `insert`, `delete`, `upsert`);
/// - изменения транслируются через Supabase Realtime (Postgres Changes);
/// - доступ к данным пользователя ограничен RLS-политиками по `user_id`;
/// - уникальность записи обеспечивается составным ключом (`user_id`, `product_id`).
///
/// Архитектурная модель:
/// - Supabase является источником истины;
/// - локальный слой (Core Data) используется как быстрый кэш и источник данных для UI;
/// - UI подписывается только на локальный паблишер;
/// - все изменения с сервера автоматически синхронизируются в локальное хранилище.
///
/// Состав:
/// - `remote`: Supabase-слой для работы с таблицей `favorite_items`;
/// - `local`: локальное Core Data-хранилище избранного;
/// - `catalog`: локальный каталог для получения метаданных товара;
/// - `userId`: идентификатор текущего пользователя;
/// - `itemsSubject`: Combine-паблишер актуального состояния избранного.
///
/// Основные функции:
/// - `observeItems()` — реактивное наблюдение за списком избранных;
/// - `observeIds()` — наблюдение за ID избранных товаров (удобно для UI-состояний);
/// - `refresh(uid:)` — принудительная синхронизация с Supabase;
/// - `add(productId:)` — добавление товара в избранное;
/// - `remove(productId:)` — удаление товара;
/// - `toggle(productId:)` — переключение состояния избранного;
/// - `clear()` — полная очистка избранного пользователя.
///
/// Особенности реализации:
/// - синхронизация реализована реактивно через Combine;
/// - `remote.listen` автоматически обновляет локальный слой;
/// - UI не взаимодействует напрямую с Supabase;
/// - поддерживает офлайн-режим за счёт локального Core Data слоя.

final class DefaultFavoritesRepository: FavoritesRepository {
    
    // MARK: - Deps
    
    private let remote: FavoritesStoreProtocol
    private let local: FavoritesLocalStore
    private let catalog: CatalogLocalStore
    private let userId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private let itemsSubject = CurrentValueSubject<[FavoriteItem], Never>([])
    
    // MARK: - Init
    
    init(
        remote: FavoritesStoreProtocol,
        local: FavoritesLocalStore,
        catalog: CatalogLocalStore,
        userId: String
    ) {
        self.remote = remote
        self.local = local
        self.catalog = catalog
        self.userId = userId
        bindStreams()
    }
    
    // MARK: - Observe
    
    func observeItems() -> AnyPublisher<[FavoriteItem], Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    
    func observeIds() -> AnyPublisher<Set<String>, Never> {
        observeItems()
            .map { Set($0.map(\.productId)) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sync
    
    func refresh(uid: String) async throws {
        let dtos = try await remote.fetch(uid: uid)
        local.replaceAll(userId: userId, with: dtos)
    }
    
    // MARK: - CRUD
    
    func add(productId: String) async throws {
        let ids = Set(itemsSubject.value.map(\.productId))
        guard !ids.contains(productId) else { return }
        guard let meta = catalog.meta(for: productId) else { return }
        
        let dto = FavoriteDTO(
            userId: userId,
            productId: productId,
            brandName: meta.brandName,
            title: meta.title,
            imageURL: meta.imageURL?.absoluteString,
            updatedAt: Date(),
            price: meta.price
        )
        
        // 1) Optimistic local update (мгновенный UI + правильное состояние после перезапуска)
        local.upsert(userId: userId, dto: dto)
        
        // 2) Remote update
        do {
            try await remote.add(uid: userId, dto: dto)
        } catch {
            // 3) Safe recovery: приводим local к источнику истины
            try? await refresh(uid: userId)
            throw error
        }
    }
    
    func remove(productId: String) async throws {
        let ids = Set(itemsSubject.value.map(\.productId))
        guard ids.contains(productId) else { return }
        
        // 1) Optimistic local update
        local.remove(userId: userId, productId: productId)
        
        // 2) Remote update
        do {
            try await remote.remove(uid: userId, productId: productId)
        } catch {
            // 3) Safe recovery
            try? await refresh(uid: userId)
            throw error
        }
    }
    
    func toggle(productId: String) async throws {
        let ids = Set(itemsSubject.value.map(\.productId))
        if ids.contains(productId) {
            try await remove(productId: productId)
        } else {
            try await add(productId: productId)
        }
    }
    
    func clear() async throws {
        // 1) Optimistic local update
        local.clear(userId: userId)
        
        // 2) Remote update
        do {
            try await remote.clear(uid: userId)
        } catch {
            // 3) Safe recovery
            try? await refresh(uid: userId)
            throw error
        }
    }
    
    // MARK: - Streams
    
    private func bindStreams() {
        local.observeItems(userId: userId)
            .subscribe(itemsSubject)
            .store(in: &bag)
        
        remote.listen(uid: userId)
            .sink { [weak self] dtos in
                guard let self else { return }
                self.local.replaceAll(userId: self.userId, with: dtos)
            }
            .store(in: &bag)
    }
}
