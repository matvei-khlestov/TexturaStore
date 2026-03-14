//
//  SupabaseOrdersStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation
import Combine
import Supabase

/// Supabase-реализация `OrdersStoreProtocol`.
///
/// Назначение:
/// - управляет заказами пользователя через Supabase (PostgREST + Realtime);
/// - выполняет загрузку, создание, обновление статуса и очистку заказов;
/// - предоставляет реактивный поток изменений списка заказов.
///
/// Контекст Supabase:
/// - данные хранятся в таблице `orders`;
/// - идентификация пользователя — через поле `user_id`;
/// - позиции заказа хранятся в поле `items`;
/// - изменения транслируются через Supabase Realtime (Postgres Changes).
final class SupabaseOrdersStore: OrdersStoreProtocol {
    
    // MARK: - Deps
    
    private let supabase: SupabaseClient
    
    // MARK: - Init
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Fetch
    
    func fetchOrders(uid: String) async throws -> [OrderDTO] {
        let response = try await supabase
            .from(Tables.orders)
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .execute()
        
        return try SupabaseDecoding.decodeArray(OrderDTO.self, from: response.data)
    }
    
    // MARK: - Create
    
    func createOrder(uid: String, dto: OrderDTO) async throws {
        let payload = OrderInsertPayload(
            id: dto.id,
            userId: uid,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            status: dto.status,
            receiveAddress: dto.receiveAddress,
            paymentMethod: dto.paymentMethod,
            comment: dto.comment,
            phoneE164: dto.phoneE164,
            items: dto.items
        )
        
        _ = try await supabase
            .from(Tables.orders)
            .insert(payload)
            .execute()
    }
    
    // MARK: - Update
    
    func updateStatus(
        uid: String,
        orderId: String,
        status: OrderStatus
    ) async throws {
        let payload = OrderStatusUpdatePayload(
            status: status,
            updatedAt: Date()
        )
        
        _ = try await supabase
            .from(Tables.orders)
            .update(payload)
            .eq("user_id", value: uid)
            .eq("id", value: orderId)
            .execute()
    }
    
    // MARK: - Clear
    
    func clear(uid: String) async throws {
        _ = try await supabase
            .from(Tables.orders)
            .delete()
            .eq("user_id", value: uid)
            .execute()
    }
    
    // MARK: - Realtime
    
    func listenOrders(uid: String) -> AnyPublisher<[OrderDTO], Never> {
        SupabaseRealtimeListener.listen(
            supabase: supabase,
            channelName: "orders-\(uid)",
            table: Tables.orders,
            fetch: { [weak self] in
                guard let self else { return [] }
                return (try? await self.fetchOrders(uid: uid)) ?? []
            }
        )
    }
}

// MARK: - Private helpers

private extension SupabaseOrdersStore {
    
    enum Tables {
        static let orders = "orders"
    }
}

// MARK: - Payloads

private extension SupabaseOrdersStore {
    
    struct OrderInsertPayload: Encodable {
        let id: String
        let userId: String
        let createdAt: Date
        let updatedAt: Date
        let status: OrderStatus
        let receiveAddress: String
        let paymentMethod: String
        let comment: String?
        let phoneE164: String?
        let items: [OrderItemDTO]
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case status
            case receiveAddress = "receive_address"
            case paymentMethod = "payment_method"
            case comment
            case phoneE164 = "phone_e164"
            case items
        }
    }
    
    struct OrderStatusUpdatePayload: Encodable {
        let status: OrderStatus
        let updatedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case status
            case updatedAt = "updated_at"
        }
    }
}
