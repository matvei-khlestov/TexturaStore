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
        
        return try decodeArray(CartDTO.self, from: response.data)
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
        let subject = PassthroughSubject<[CartDTO], Never>()
        let channel = supabase.channel("cart-\(uid)")
        
        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: Tables.cartItems
        )
        
        let task = Task { [weak self] in
            guard let self else { return }
            
            // Initial load
            let initial = (try? await self.fetchCart(uid: uid)) ?? []
            subject.send(initial)
            
            do {
                try await channel.subscribeWithError()
            } catch {
                return
            }
            
            for await _ in changes {
                let updated = (try? await self.fetchCart(uid: uid)) ?? []
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
            
            return try decode(CartDTO.self, from: response.data)
        } catch {
            if isNoRowsError(error) {
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

// MARK: - Decoding

private extension SupabaseCartStore {
    
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
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try Self.decoder.decode(T.self, from: data)
    }
    
    func decodeArray<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] {
        try Self.decoder.decode([T].self, from: data)
    }
}

// MARK: - Errors

private extension SupabaseCartStore {
    
    func isNoRowsError(_ error: Error) -> Bool {
        let ns = error as NSError
        let text = [
            ns.localizedDescription,
            ns.localizedFailureReason ?? "",
            ns.localizedRecoverySuggestion ?? "",
            String(describing: error)
        ]
        .joined(separator: " | ")
        .lowercased()
        
        return text.contains("no rows")
        || text.contains("multiple (or no) rows returned")
        || text.contains("json object requested")
        || text.contains("pgrst116")
    }
}

enum SupabaseDateParser {
    
    static func parse(_ s: String) -> Date? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        return iso8601Fractional.date(from: trimmed)
        ?? iso8601Plain.date(from: trimmed)
        ?? postgresFallback1.date(from: trimmed)
        ?? postgresFallback2.date(from: trimmed)
    }
}

// MARK: - Formatters

private extension SupabaseDateParser {
    
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
    
    /// Частый fallback для Postgres: `2026-02-21 10:15:30+00:00`
    static let postgresFallback1: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        return f
    }()
    
    /// Альтернативный fallback: `2026-02-21T10:15:30+00:00`
    static let postgresFallback2: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return f
    }()
}
