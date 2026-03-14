//
//  SupabaseFavoritesStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine
import Supabase

/// Supabase-реализация `FavoritesStoreProtocol`.
///
/// Назначение:
/// - управляет избранным пользователя через Supabase (PostgREST + Realtime);
/// - выполняет CRUD-операции над элементами избранного;
/// - предоставляет реактивный поток изменений избранного.
///
/// Контекст Supabase:
/// - данные хранятся в таблице `favorite_items`;
/// - идентификация пользователя — через поле `user_id`;
/// - уникальность товара в избранном обеспечивается парой (`user_id`, `product_id`);
/// - изменения транслируются через Supabase Realtime (Postgres Changes).
final class SupabaseFavoritesStore: FavoritesStoreProtocol {
    
    // MARK: - Deps
    
    private let supabase: SupabaseClient
    
    // MARK: - Init
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Fetch
    
    func fetch(uid: String) async throws -> [FavoriteDTO] {
        let response = try await supabase
            .from(Tables.favoriteItems)
            .select()
            .eq("user_id", value: uid)
            .execute()
        
        return try SupabaseDecoding.decodeArray(FavoriteDTO.self, from: response.data)
    }
    
    // MARK: - Add
    
    func add(uid: String, dto: FavoriteDTO) async throws {
        let payload = FavoriteUpsertPayload(
            userId: uid,
            productId: dto.productId,
            brandName: dto.brandName,
            title: dto.title,
            imageURL: dto.imageURL ?? "",
            price: dto.price,
            updatedAt: Date()
        )
        
        _ = try await supabase
            .from(Tables.favoriteItems)
            .upsert(payload, onConflict: "user_id,product_id")
            .execute()
    }
    
    // MARK: - Remove / Clear
    
    func remove(uid: String, productId: String) async throws {
        _ = try await supabase
            .from(Tables.favoriteItems)
            .delete()
            .eq("user_id", value: uid)
            .eq("product_id", value: productId)
            .execute()
    }
    
    func clear(uid: String) async throws {
        _ = try await supabase
            .from(Tables.favoriteItems)
            .delete()
            .eq("user_id", value: uid)
            .execute()
    }
    
    // MARK: - Realtime
    
    func listen(uid: String) -> AnyPublisher<[FavoriteDTO], Never> {
        SupabaseRealtimeListener.listen(
            supabase: supabase,
            channelName: "favorites-\(uid)",
            table: Tables.favoriteItems,
            fetch: { [weak self] in
                guard let self else { return [] }
                return (try? await self.fetch(uid: uid)) ?? []
            }
        )
    }
}

// MARK: - Private helpers

private extension SupabaseFavoritesStore {
    
    enum Tables {
        static let favoriteItems = "favorite_items"
    }
}

// MARK: - Payloads

private extension SupabaseFavoritesStore {
    
    struct FavoriteUpsertPayload: Encodable {
        let userId: String
        let productId: String
        let brandName: String
        let title: String
        let imageURL: String
        let price: Double
        let updatedAt: Date
    }
}

// MARK: - CodingKeys

private extension SupabaseFavoritesStore.FavoriteUpsertPayload {
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case productId = "product_id"
        case brandName = "brand_name"
        case title
        case imageURL = "image_url"
        case price
        case updatedAt = "updated_at"
    }
}
