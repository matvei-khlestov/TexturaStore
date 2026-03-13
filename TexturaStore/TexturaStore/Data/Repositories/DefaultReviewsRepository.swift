//
//  DefaultReviewsRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import Foundation
import Combine

/// Класс `DefaultReviewsRepository` — реализация репозитория отзывов.
///
/// Назначение:
/// - объединяет работу удалённого источника (`ReviewsStoreProtocol`) и локального (`ReviewsLocalStore`);
/// - обеспечивает реактивное наблюдение и синхронизацию отзывов товара между Supabase и Core Data.
///
/// Состав:
/// - `remote`: Supabase-хранилище отзывов;
/// - `local`: локальное Core Data-хранилище отзывов;
/// - `productId`: идентификатор товара, для которого работает репозиторий;
/// - `subject`: Combine-паблишер, транслирующий текущее состояние списка отзывов.
///
/// Основные функции:
/// - `observeReviews()` — реактивное наблюдение за отзывами;
/// - `refresh(productId:)` — одноразовое обновление локальных данных из Supabase;
/// - `addReview(...)` — создание нового отзыва;
/// - `updateReview(...)` — обновление существующего отзыва;
/// - `remove(uid:reviewId:)` — удаление отзыва пользователя.
///
/// Особенности реализации:
/// - при инициализации выполняет one-shot `refresh` для синхронизации локального кеша;
/// - затем подключает realtime (`listen`) и поддерживает локальное хранилище в актуальном состоянии;
/// - локальный стор транслирует изменения через Combine;
/// - предусмотрена фильтрация дубликатов по массиву `ProductReviewDTO`.
final class DefaultReviewsRepository: ReviewsRepository {
    
    // MARK: - Deps
    
    private let remote: any ReviewsStoreProtocol
    private let local: any ReviewsLocalStore
    private let productId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private let subject = CurrentValueSubject<[ProductReview], Never>([])
    
    // MARK: - Init
    
    init(
        remote: any ReviewsStoreProtocol,
        local: any ReviewsLocalStore,
        productId: String
    ) {
        self.remote = remote
        self.local = local
        self.productId = productId
        
        bindReviewStreams()
    }
    
    // MARK: - Public API
    
    func observeReviews() -> AnyPublisher<[ProductReview], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func refresh(productId: String) async throws {
        let dtos = try await remote.fetch(productId: productId)
        local.replace(productId: productId, with: dtos)
    }
    
    func addReview(
        productId: String,
        userId: String,
        userName: String,
        rating: Int,
        comment: String
    ) async throws {
        let now = Date()
        
        let dto = ProductReviewDTO(
            id: UUID().uuidString.lowercased(),
            productId: productId,
            userId: userId,
            rating: rating,
            comment: comment,
            userName: userName,
            createdAt: now,
            updatedAt: now
        )
        
        try await remote.add(dto: dto)
    }
    
    func updateReview(
        reviewId: String,
        productId: String,
        userId: String,
        userName: String,
        rating: Int,
        comment: String,
        createdAt: Date
    ) async throws {
        let dto = ProductReviewDTO(
            id: reviewId,
            productId: productId,
            userId: userId,
            rating: rating,
            comment: comment,
            userName: userName,
            createdAt: createdAt,
            updatedAt: Date()
        )
        
        try await remote.update(dto: dto)
    }
    
    func remove(uid: String, reviewId: String) async throws {
        try await remote.remove(uid: uid, reviewId: reviewId)
    }
}

// MARK: - Private

private extension DefaultReviewsRepository {
    
    func bindReviewStreams() {
        local.listen(productId: productId)
            .subscribe(subject)
            .store(in: &bag)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.refresh(productId: self.productId)
            } catch {
#if DEBUG
                print("🔴 [ReviewsRepository] initial refresh failed:", error)
#endif
            }
        }
        
        remote.listen(productId: productId)
            .removeDuplicates()
            .sink { [weak self] dtos in
                guard let self else { return }
                self.local.replace(productId: self.productId, with: dtos)
            }
            .store(in: &bag)
    }
}
