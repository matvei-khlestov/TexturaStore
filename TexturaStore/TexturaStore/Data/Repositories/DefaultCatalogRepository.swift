//
//  DefaultCatalogRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine

/// `DefaultCatalogRepository` — реализация `CatalogRepository`.
///
/// Назначение:
/// - читает данные **только** из локального слоя (`CatalogLocalStore`) через Combine-потоки;
/// - синхронизирует локальный Core Data каталог с Supabase:
///   - одноразово (`refreshAll()`),
///   - и в реальном времени (`startRealtimeSync()`).
///
/// Состав:
/// - `remote`: Supabase-источник (`CatalogStoreProtocol`);
/// - `local`: Core Data store (`CatalogLocalStore`);
/// - `bag`: набор подписок Combine (realtime);
/// - `isRealtimeStarted`: защита от двойного старта realtime.
///
/// Особенности:
/// - репозиторий **не создаёт FRC сам** — универсальные потоки и удержание live-stream’ов
///   реализованы в `CoreDataCatalogStore` (NEW observeProducts API).
final class DefaultCatalogRepository: CatalogRepository {
    
    // MARK: - Deps
    
    private let remote: CatalogStoreProtocol
    private let local: CatalogLocalStore
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var isRealtimeStarted = false
    
    // MARK: - Init
    
    init(remote: CatalogStoreProtocol, local: CatalogLocalStore) {
        self.remote = remote
        self.local = local
    }
    
    // MARK: - Observe (local)
    
    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        colorIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[Product], Never> {
        local.observeProducts(
            query: query,
            categoryIds: categoryIds,
            brandIds: brandIds,
            colorIds: colorIds,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
    }
    
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never> {
        local.observeProducts(query: query, categoryId: categoryId)
    }
    
    func observeCategories() -> AnyPublisher<[Category], Never> {
        local.observeCategories()
    }
    
    func observeBrands() -> AnyPublisher<[Brand], Never> {
        local.observeBrands()
    }
    
    func observeProductColors() -> AnyPublisher<[ProductColor], Never> {
        local.observeProductColors()
    }
    
    func observeProduct(id: String) -> AnyPublisher<Product?, Never> {
        local.observeProduct(id: id)
    }
    
    // MARK: - Refresh
    
    func refreshAll() async throws {
        print("🟣 refreshAll() called")
        async let p = remote.fetchProducts()
        async let c = remote.fetchCategories()
        async let b = remote.fetchBrands()
        async let col = remote.fetchProductColors()

        let (products, categories, brands, colors) = try await (p, c, b, col)

        local.upsertProducts(products)
        local.upsertCategories(categories)
        local.upsertBrands(brands)
        local.upsertProductColors(colors)
    }
    
    // MARK: - Realtime
    
    /// Запускает realtime-синхронизацию.
    ///
    /// Важно:
    /// - метод **не** делает `refreshAll()` (одноразовая синхронизация должна вызываться отдельно через `refreshAll()`),
    ///   чтобы не было дублирующих апсертов (refresh + initial snapshot из realtime).
    func startRealtimeSync() {
        guard !isRealtimeStarted else { return }
        isRealtimeStarted = true
        
        remote.listenProducts()
            .sink { [weak self] dtos in
                self?.local.upsertProducts(dtos)
            }
            .store(in: &bag)
        
        remote.listenCategories()
            .sink { [weak self] dtos in
                self?.local.upsertCategories(dtos)
            }
            .store(in: &bag)
        
        remote.listenBrands()
            .sink { [weak self] dtos in
                self?.local.upsertBrands(dtos)
            }
            .store(in: &bag)
        
        remote.listenProductColors()
            .sink { [weak self] dtos in
                self?.local.upsertProductColors(dtos)
            }
            .store(in: &bag)
    }
    
    func stopRealtimeSync() {
        isRealtimeStarted = false
        bag.removeAll()
    }
}
