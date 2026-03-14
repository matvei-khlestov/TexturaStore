//
//  CatalogRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Combine
import Foundation

/// Протокол `CatalogRepository`.
///
/// Определяет единый интерфейс доступа к данным каталога:
/// продукты, категории, бренды и цвета товаров.
///
/// Репозиторий объединяет:
/// - локальный слой (`CatalogLocalStore`) — источник реактивных данных для UI (Core Data/FRC);
/// - удалённый слой (`CatalogStoreProtocol`) — источник данных из Supabase (one-shot + realtime).
///
/// Основные задачи:
/// - предоставление реактивных потоков локальных данных (`observe*`);
/// - синхронизация локального каталога с сервером (`refreshAll`);
/// - фоновая синхронизация в реальном времени (`startRealtimeSync`, `stopRealtimeSync`);
/// - единый интерфейс фильтрации продуктов по категориям/брендам/цветам/цене.
///
/// Используется в:
/// - `CatalogViewModel`, `CategoryProductsViewModel`, `CatalogFilterViewModel`, `ProductDetailsViewModel`.
protocol CatalogRepository: AnyObject {
    
    // MARK: - Observe (local, reactive)
    
    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        colorIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[Product], Never>
    
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never>
    
    func observeCategories() -> AnyPublisher<[Category], Never>
    
    func observeBrands() -> AnyPublisher<[Brand], Never>
    
    func observeProductColors() -> AnyPublisher<[ProductColor], Never>
    
    func observeProduct(id: String) -> AnyPublisher<Product?, Never>
    
    // MARK: - Refresh
    
    func refreshAll() async throws
    
    // MARK: - Realtime
    
    func startRealtimeSync()
    func stopRealtimeSync()
}

// MARK: - Backward Compatibility

extension CatalogRepository {
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never> {
        observeProducts(
            query: query,
            categoryIds: categoryId.flatMap { [$0] }.map(Set.init),
            brandIds: nil,
            colorIds: nil,
            minPrice: nil,
            maxPrice: nil
        )
    }
}
