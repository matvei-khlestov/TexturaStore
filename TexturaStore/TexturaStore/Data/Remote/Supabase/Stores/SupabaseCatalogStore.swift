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
/// - даты декодируются устойчиво: ISO8601 (с/без fractional seconds) + fallback форматы Postgres.
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
        
        return try decodeArray(ProductDTO.self, from: response.data)
    }
    
    func listenProducts() -> AnyPublisher<[ProductDTO], Never> {
        listenTable(
            table: Tables.products,
            channelName: "catalog-products",
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
        
        return try decodeArray(CategoryDTO.self, from: response.data)
    }
    
    func listenCategories() -> AnyPublisher<[CategoryDTO], Never> {
        listenTable(
            table: Tables.categories,
            channelName: "catalog-categories",
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
        
        return try decodeArray(BrandDTO.self, from: response.data)
    }
    
    func listenBrands() -> AnyPublisher<[BrandDTO], Never> {
        listenTable(
            table: Tables.brands,
            channelName: "catalog-brands",
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
        
        return try decodeArray(ProductColorDTO.self, from: response.data)
    }
    
    func listenProductColors() -> AnyPublisher<[ProductColorDTO], Never> {
        listenTable(
            table: Tables.productColors,
            channelName: "catalog-product-colors",
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
    
    func listenTable<T: Sendable>(
        table: String,
        channelName: String,
        fetch: @escaping @Sendable () async -> [T]
    ) -> AnyPublisher<[T], Never> {
        let subject = PassthroughSubject<[T], Never>()
        let channel = supabase.channel(channelName)

        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: table
        )

        let task = Task { [weak self] in
            guard self != nil else { return }

            do {
                try await channel.subscribeWithError()
            } catch {
                return
            }

            for await _ in changes {
                let updated = await fetch()
                subject.send(updated)
            }

            await channel.unsubscribe()
        }

        return subject
            .handleEvents(receiveCancel: {
                task.cancel()
                Task { await channel.unsubscribe() }
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Decoding

private extension SupabaseCatalogStore {
    
    static let iso8601Fractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    static let iso8601Plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    
    static let postgresFallback1: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        return f
    }()
    
    static let postgresFallback2: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return f
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { d in
            let c = try d.singleValueContainer()
            let s = try c.decode(String.self)
            
            if let date = iso8601Fractional.date(from: s) { return date }
            if let date = iso8601Plain.date(from: s) { return date }
            if let date = postgresFallback1.date(from: s) { return date }
            if let date = postgresFallback2.date(from: s) { return date }
            
            throw DecodingError.dataCorruptedError(
                in: c,
                debugDescription: "Expected ISO8601/Postgres date, got: \(s)"
            )
        }
        return decoder
    }()
    
    func decodeArray<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] {
        try Self.decoder.decode([T].self, from: data)
    }
}
