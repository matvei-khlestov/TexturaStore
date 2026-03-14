//
//  SupabaseCartStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine
import Supabase

/// Supabase-реализация `CartStoreProtocol`.
///
/// Назначение:
/// - управляет корзиной пользователя через Supabase (PostgREST + Realtime);
/// - выполняет CRUD-операции над элементами корзины;
/// - предоставляет реактивный поток изменений корзины.
///
/// Контекст Supabase:
/// - данные хранятся в таблице `cart_items`;
/// - идентификация пользователя — через поле `user_id`;
/// - уникальность товара в корзине обеспечивается парой (`user_id`, `product_id`);
/// - изменения транслируются через Supabase Realtime (Postgres Changes).
final class SupabaseCartStore: CartStoreProtocol {
    
    // MARK: - Deps
    
    private let supabase: SupabaseClient
    
    // MARK: - Init
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Fetch
    
    func fetchCart(uid: String) async throws -> [CartDTO] {
        let response = try await supabase
            .from(Tables.cartItems)
            .select()
            .eq("user_id", value: uid)
            .execute()
        
        return try SupabaseDecoding.decodeArray(CartDTO.self, from: response.data)
    }
    
    // MARK: - Quantity operations
    
    func setQuantity(
        uid: String,
        dto: CartDTO,
        quantity: Int
    ) async throws {
        if quantity <= 0 {
            try await remove(uid: uid, productId: dto.productId)
            return
        }
        
        let payload = CartUpdatePayload(
            quantity: quantity,
            updatedAt: Date()
        )
        
        _ = try await supabase
            .from(Tables.cartItems)
            .update(payload)
            .eq("user_id", value: uid)
            .eq("product_id", value: dto.productId)
            .execute()
    }
    
    func addOrAccumulate(
        uid: String,
        dto: CartDTO,
        by delta: Int
    ) async throws {
        let current = try await fetchItem(uid: uid, productId: dto.productId)
        
        let newQuantity = (current?.quantity ?? 0) + delta
        
        if newQuantity <= 0 {
            try await remove(uid: uid, productId: dto.productId)
            return
        }
        
        let payload = CartUpsertPayload(
            userId: uid,
            productId: dto.productId,
            brandName: dto.brandName,
            title: dto.title,
            price: dto.price,
            imageURL: dto.imageURL ?? "",
            quantity: newQuantity,
            updatedAt: Date()
        )
        
        _ = try await supabase
            .from(Tables.cartItems)
            .upsert(payload, onConflict: "user_id,product_id")
            .execute()
    }
    
    // MARK: - Remove / Clear
    
    func remove(uid: String, productId: String) async throws {
        _ = try await supabase
            .from(Tables.cartItems)
            .delete()
            .eq("user_id", value: uid)
            .eq("product_id", value: productId)
            .execute()
    }
    
    func clear(uid: String) async throws {
        _ = try await supabase
            .from(Tables.cartItems)
            .delete()
            .eq("user_id", value: uid)
            .execute()
    }
    
    // MARK: - Realtime
    
    func listenCart(uid: String) -> AnyPublisher<[CartDTO], Never> {
        SupabaseRealtimeListener.listen(
            supabase: supabase,
            channelName: "cart-\(uid)",
            table: Tables.cartItems,
            fetch: { [weak self] in
                guard let self else { return [] }
                return (try? await self.fetchCart(uid: uid)) ?? []
            }
        )
    }
}

// MARK: - Private helpers

private extension SupabaseCartStore {
    
    enum Tables {
        static let cartItems = "cart_items"
    }
    
    func fetchItem(uid: String, productId: String) async throws -> CartDTO? {
        do {
            let response = try await supabase
                .from(Tables.cartItems)
                .select()
                .eq("user_id", value: uid)
                .eq("product_id", value: productId)
                .single()
                .execute()
            
            return try SupabaseDecoding.decode(CartDTO.self, from: response.data)
        } catch {
            if SupabaseErrorMatcher.isNoRowsError(error) {
                return nil
            }
            throw error
        }
    }
}

// MARK: - Payloads

private extension SupabaseCartStore {
    
    struct CartUpsertPayload: Encodable {
        let userId: String
        let productId: String
        let brandName: String
        let title: String
        let price: Double
        let imageURL: String
        let quantity: Int
        let updatedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case productId = "product_id"
            case brandName = "brand_name"
            case title
            case price
            case imageURL = "image_url"
            case quantity
            case updatedAt = "updated_at"
        }
    }
    
    struct CartUpdatePayload: Encodable {
        let quantity: Int
        let updatedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case quantity
            case updatedAt = "updated_at"
        }
    }
}
