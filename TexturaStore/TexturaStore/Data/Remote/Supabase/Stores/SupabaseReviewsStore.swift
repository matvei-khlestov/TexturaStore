//
//  SupabaseReviewsStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation
import Combine
import Supabase

/// Supabase-реализация `ReviewsStoreProtocol`.
///
/// Назначение:
/// - управляет отзывами товаров через Supabase;
/// - выполняет CRUD-операции над отзывами;
/// - предоставляет realtime обновления списка отзывов.
///
/// Контекст Supabase:
/// - данные хранятся в таблице `product_reviews`;
/// - идентификация пользователя осуществляется через `user_id`;
/// - изменения транслируются через Supabase Realtime.
final class SupabaseReviewsStore: ReviewsStoreProtocol {
    
    // MARK: - Deps
    
    private let supabase: SupabaseClient
    
    // MARK: - Init
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Fetch
    
    func fetch(productId: String) async throws -> [ProductReviewDTO] {
        let response = try await supabase
            .from(Tables.productReviews)
            .select()
            .eq("product_id", value: productId)
            .order("created_at", ascending: false)
            .execute()
        
        return try decodeArray(ProductReviewDTO.self, from: response.data)
    }
    
    // MARK: - Add
    
    func add(dto: ProductReviewDTO) async throws {
        let payload = ReviewInsertPayload(
            id: dto.id,
            productId: dto.productId,
            userId: dto.userId,
            rating: dto.rating,
            comment: dto.comment,
            userName: dto.userName,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
        
        _ = try await supabase
            .from(Tables.productReviews)
            .insert(payload)
            .execute()
    }
    
    // MARK: - Update
    
    func update(dto: ProductReviewDTO) async throws {
        let payload = ReviewUpdatePayload(
            rating: dto.rating,
            comment: dto.comment,
            updatedAt: Date()
        )
        
        _ = try await supabase
            .from(Tables.productReviews)
            .update(payload)
            .eq("id", value: dto.id)
            .eq("user_id", value: dto.userId)
            .execute()
    }
    
    // MARK: - Remove
    
    func remove(uid: String, reviewId: String) async throws {
        _ = try await supabase
            .from(Tables.productReviews)
            .delete()
            .eq("id", value: reviewId)
            .eq("user_id", value: uid)
            .execute()
    }
    
    // MARK: - Realtime
    
    func listen(productId: String) -> AnyPublisher<[ProductReviewDTO], Never> {
        let subject = PassthroughSubject<[ProductReviewDTO], Never>()
        let channel = supabase.channel("reviews-\(productId)")
        
        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: Tables.productReviews
        )
        
        let task = Task { [weak self] in
            guard let self else { return }
            
            let initial = (try? await self.fetch(productId: productId)) ?? []
            subject.send(initial)
            
            do {
                try await channel.subscribeWithError()
            } catch {
                return
            }
            
            for await _ in changes {
                let updated = (try? await self.fetch(productId: productId)) ?? []
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

private extension SupabaseReviewsStore {
    
    enum Tables {
        static let productReviews = "product_reviews"
    }
}

private extension SupabaseReviewsStore {
    
    struct ReviewInsertPayload: Encodable {
        let id: String
        let productId: String
        let userId: String
        let rating: Int
        let comment: String?
        let userName: String
        let createdAt: Date
        let updatedAt: Date
    }
    
    struct ReviewUpdatePayload: Encodable {
        let rating: Int
        let comment: String?
        let updatedAt: Date
    }
}

private extension SupabaseReviewsStore.ReviewInsertPayload {
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case userId = "user_id"
        case rating
        case comment
        case userName = "user_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

private extension SupabaseReviewsStore.ReviewUpdatePayload {
    
    enum CodingKeys: String, CodingKey {
        case rating
        case comment
        case updatedAt = "updated_at"
    }
}

private extension SupabaseReviewsStore {
    
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
