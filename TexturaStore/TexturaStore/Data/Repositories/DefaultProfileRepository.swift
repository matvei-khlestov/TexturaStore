//
//  DefaultProfileRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation
import Combine

/// Класс `DefaultProfileRepository` — реализация репозитория профиля.
///
/// Назначение:
/// - объединяет работу удалённого источника (`ProfileStoreProtocol`) и локального (`ProfileLocalStore`);
/// - обеспечивает реактивное наблюдение и синхронизацию профиля пользователя между Supabase и Core Data.
///
/// Состав:
/// - `remote`: Supabase-хранилище профилей пользователей;
/// - `local`: локальное Core Data-хранилище профиля;
/// - `userId`: идентификатор текущего пользователя;
/// - `subject`: Combine-паблишер, транслирующий текущее состояние профиля пользователя.
///
/// Основные функции:
/// - `observeProfile()` — реактивное наблюдение за профилем в реальном времени;
/// - `refresh(uid:)` — одноразовое обновление локальных данных из Supabase;
/// - `ensureInitialProfile(uid:name:email:)` — создание или обновление базового профиля при регистрации/входе;
/// - `updateName(uid:name:)`, `updateEmail(uid:email:)`, `updatePhone(uid:phone:)` — обновление отдельных полей профиля.
///
/// Особенности реализации:
/// - изменения из удалённого источника обновляют локальное хранилище через `listenProfile`;
/// - локальный стор транслирует изменения через Combine (`CurrentValueSubject`);
/// - предусмотрена фильтрация дубликатов по ключевым полям и `updatedAt`.
final class DefaultProfileRepository: ProfileRepository {
    
    // MARK: - Deps
    
    private let remote: any ProfileStoreProtocol
    private let local: any ProfileLocalStore
    private let userId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    
    // MARK: - Init
    
    init(
        remote: any ProfileStoreProtocol,
        local: any ProfileLocalStore,
        userId: String
    ) {
        self.remote = remote
        self.local = local
        self.userId = userId
        
        bindProfileStreams()
    }
    
    // MARK: - Public API
    
    func observeProfile() -> AnyPublisher<UserProfile?, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func refresh(uid: String) async throws {
        if let dto = try await remote.fetchProfile(uid: uid) {
            local.upsertProfile(dto)
        }
    }
    
    func ensureInitialProfile(uid: String, name: String, email: String) async throws {
        print("🟡 ProfileRepository.ensureInitialProfile start uid=\(uid)")
        try await remote.ensureInitialUserProfile(uid: uid, name: name, email: email)
        print("🟢 ProfileRepository.ensureInitialProfile success uid=\(uid)")
    }
    
    func updateName(uid: String, name: String) async throws {
        try await remote.updateName(uid: uid, name: name)
    }
    
    func updateEmail(uid: String, email: String) async throws {
        try await remote.updateEmail(uid: uid, email: email)
    }
    
    func updatePhone(uid: String, phone: String) async throws {
        try await remote.updatePhone(uid: uid, phone: phone)
    }
}

// MARK: - Private

private extension DefaultProfileRepository {
    
    func bindProfileStreams() {
        // Local -> UI stream
        local.observeProfile(userId: userId)
            .subscribe(subject)
            .store(in: &bag)
        
        // Remote -> Local (dedup)
        remote.listenProfile(uid: userId)
            .compactMap { $0 }
            .removeDuplicates(by: { old, new in
                old.name == new.name &&
                old.email == new.email &&
                old.phone == new.phone &&
                old.updatedAt == new.updatedAt
            })
            .sink { [weak self] dto in
                self?.local.upsertProfile(dto)
            }
            .store(in: &bag)
    }
}
