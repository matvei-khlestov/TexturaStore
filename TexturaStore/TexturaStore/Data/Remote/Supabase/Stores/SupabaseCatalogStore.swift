//
//  SupabaseCatalogStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import Foundation
import Combine
import Supabase

/// Supabase-реализация `CatalogStoreProtocol`.
///
/// Назначение:
/// - выполняет одноразовую загрузку данных каталога из Supabase (PostgREST);
/// - предоставляет Combine-паблишеры для реактивного обновления данных через Supabase Realtime (Postgres Changes);
/// - возвращает DTO-модели (`ProductDTO`, `CategoryDTO`, `BrandDTO`, `ProductColorDTO`) для дальнейшего маппинга в Domain.
///
/// Особенности:
/// - `fetch*` методы читают данные из таблиц Supabase с фильтрацией `is_active == true`;
/// - `listen*` методы подписываются на изменения таблиц через Realtime и при событиях обновляют данные;
/// - даты декодируются устойчиво: через общие компоненты `SupabaseDateParser` и `SupabaseDecoding`.
final class SupabaseCatalogStore: CatalogStoreProtocol {
    
    // MARK: - Deps
    
    private let supabase: SupabaseClient
    
    // MARK: - Init
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Products
    
    func fetchProducts() async throws -> [ProductDTO] {
        let response = try await supabase
            .from(Tables.products)
            .select()
            .eq("is_active", value: true)
            .execute()
        
        return try SupabaseDecoding.decodeArray(ProductDTO.self, from: response.data)
    }
    
    func listenProducts() -> AnyPublisher<[ProductDTO], Never> {
        SupabaseRealtimeListener.listen(
            supabase: supabase,
            channelName: "catalog-products",
            table: Tables.products,
            fetch: { [weak self] in
                guard let self else { return [] }
                return (try? await self.fetchProducts()) ?? []
            }
        )
    }
    
    // MARK: - Categories
    
    func fetchCategories() async throws -> [CategoryDTO] {
        let response = try await supabase
            .from(Tables.categories)
            .select()
            .eq("is_active", value: true)
            .execute()
        
        return try SupabaseDecoding.decodeArray(CategoryDTO.self, from: response.data)
    }
    
    func listenCategories() -> AnyPublisher<[CategoryDTO], Never> {
        SupabaseRealtimeListener.listen(
            supabase: supabase,
            channelName: "catalog-categories",
            table: Tables.categories,
            fetch: { [weak self] in
                guard let self else { return [] }
                return (try? await self.fetchCategories()) ?? []
            }
        )
    }
    
    // MARK: - Brands
    
    func fetchBrands() async throws -> [BrandDTO] {
        let response = try await supabase
            .from(Tables.brands)
            .select()
            .eq("is_active", value: true)
            .execute()
        
        return try SupabaseDecoding.decodeArray(BrandDTO.self, from: response.data)
    }
    
    func listenBrands() -> AnyPublisher<[BrandDTO], Never> {
        SupabaseRealtimeListener.listen(
            supabase: supabase,
            channelName: "catalog-brands",
            table: Tables.brands,
            fetch: { [weak self] in
                guard let self else { return [] }
                return (try? await self.fetchBrands()) ?? []
            }
        )
    }
    
    // MARK: - Product Colors
    
    func fetchProductColors() async throws -> [ProductColorDTO] {
        let response = try await supabase
            .from(Tables.productColors)
            .select()
            .eq("is_active", value: true)
            .execute()
        
        return try SupabaseDecoding.decodeArray(ProductColorDTO.self, from: response.data)
    }
    
    func listenProductColors() -> AnyPublisher<[ProductColorDTO], Never> {
        SupabaseRealtimeListener.listen(
            supabase: supabase,
            channelName: "catalog-product-colors",
            table: Tables.productColors,
            fetch: { [weak self] in
                guard let self else { return [] }
                return (try? await self.fetchProductColors()) ?? []
            }
        )
    }
}

// MARK: - Private

private extension SupabaseCatalogStore {
    
    enum Tables {
        static let products = "products"
        static let categories = "categories"
        static let brands = "brands"
        static let productColors = "colors"
    }
}
