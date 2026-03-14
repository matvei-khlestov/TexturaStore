//
//  ProfileUserViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import Foundation
import Combine

/// ViewModel `ProfileUserViewModel` для экрана профиля пользователя.
///
/// Основные задачи:
/// - Наблюдение за изменениями профиля через `ProfileRepository`;
/// - Отображение имени, почты и данных пользователя в интерфейсе;
/// - Управление действиями профиля: выход из аккаунта и удаление учётной записи через `AuthServiceProtocol`;
/// - Загрузка аватара из локального хранилища через `AvatarStorageServiceProtocol`.
///
/// Обеспечивает реактивное обновление данных через Combine
/// и реализует базовую бизнес-логику пользовательского профиля.

final class ProfileUserViewModel: ProfileUserViewModelProtocol, ObservableObject {
    
    // MARK: - Deps
    
    private let auth: AuthServiceProtocol
    private let avatarStorage: AvatarStorageServiceProtocol
    private let profileRepository: ProfileRepository
    private let userId: String

    // MARK: - State
    
    @Published private(set) var userName: String  = "—"
    @Published private(set) var userEmail: String = "—"

    var userNamePublisher: AnyPublisher<String, Never>  {
        $userName.eraseToAnyPublisher()
    }
    
    var userEmailPublisher: AnyPublisher<String, Never> {
        $userEmail.eraseToAnyPublisher()
    }

    // MARK: - Table
    
    let rows: [ProfileUserRow] = [
            .editProfile,
            .orders,
            .settings,
            .about,
            .contact,
            .privacy
        ]

    // MARK: - Internals
    
    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    
    init(
        auth: AuthServiceProtocol,
        avatarStorage: AvatarStorageServiceProtocol,
        profileRepository: ProfileRepository,
        userId: String
    ) {
        self.auth = auth
        self.avatarStorage = avatarStorage
        self.profileRepository = profileRepository
        self.userId = userId
        bindProfile()
    }

    // MARK: - Intents
    
    func logout() async throws {
        try await auth.signOut()
    }
    
    func deleteAccount() async throws {
        try await auth.deleteAccount()
    }

    // MARK: - Avatar
    
    func loadAvatarData() -> Data? { avatarStorage.loadAvatarData() }

    // MARK: - Private
    
    private func bindProfile() {
        profileRepository.observeProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.userName  = profile?.name  ?? "—"
                self?.userEmail = profile?.email ?? "—"
            }
            .store(in: &bag)
    }
}
