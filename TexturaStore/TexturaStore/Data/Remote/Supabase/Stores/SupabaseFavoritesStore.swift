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
        
        return try decodeArray(FavoriteDTO.self, from: response.data)
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
        let subject = PassthroughSubject<[FavoriteDTO], Never>()
        let channel = supabase.channel("favorites-\(uid)")
        
        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: Tables.favoriteItems
        )
        
        let task = Task { [weak self] in
            guard let self else { return }
            
            // Initial load
            let initial = (try? await self.fetch(uid: uid)) ?? []
            subject.send(initial)
            
            do {
                try await channel.subscribeWithError()
            } catch {
                return
            }
            
            for await _ in changes {
                let updated = (try? await self.fetch(uid: uid)) ?? []
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

// MARK: - Decoding

private extension SupabaseFavoritesStore {
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { d in
            let c = try d.singleValueContainer()
            let s = try c.decode(String.self)
            
            if let date = SupabaseDateParser.parse(s) { return date }
            
            throw DecodingError.dataCorruptedError(
                in: c,
                debugDescription: "Invalid date: \(s)"
            )
        }
        return decoder
    }()
    
    func decodeArray<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] {
        try Self.decoder.decode([T].self, from: data)
    }
}
