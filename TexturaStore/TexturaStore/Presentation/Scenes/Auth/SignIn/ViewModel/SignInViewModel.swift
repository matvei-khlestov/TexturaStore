//
//  SignInViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import Foundation
import Combine

/// ViewModel `SignInViewModel` для экрана авторизации.
///
/// Отвечает за:
/// - ввод и валидацию e-mail и пароля пользователя;
/// - реактивную обработку ошибок через Combine;
/// - активацию кнопки входа при корректных данных;
/// - best-effort обновление профиля в локальном сторе после успешного логина (Variant A).
///
/// Вариант A:
/// - профиль создаётся на стороне БД триггером `auth.users -> public.profiles`;
/// - после входа мы делаем `repo.refresh(uid:)`, чтобы подтянуть профиль в Core Data.
final class SignInViewModel: SignInViewModelProtocol, ObservableObject {
    
    // MARK: - Dependencies
    
    private let validator: FormValidatingProtocol
    private let authService: AuthServiceProtocol
    
    /// Фабрика репозитория под конкретного пользователя (uid известен только после signIn).
    private let makeProfileRepository: (String) -> any ProfileRepository
    
    // MARK: - State
    
    @Published private var email: String = ""
    @Published private var password: String = ""
    
    @Published private var _emailError: String? = nil
    @Published private var _passwordError: String? = nil
    
    /// Триггер для “переинициализации” downstream (если где-то нужно).
    @Published private var _refreshId: UUID = UUID()
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        validator: FormValidatingProtocol,
        authService: AuthServiceProtocol,
        makeProfileRepository: @escaping (String) -> any ProfileRepository
    ) {
        self.validator = validator
        self.authService = authService
        self.makeProfileRepository = makeProfileRepository
        
        $email
            .map { [validator] in
                validator.validate($0, for: .email).message
            }
            .assign(to: &$_emailError)
        
        $password
            .map { [validator] in
                validator.validate($0, for: .password).message
            }
            .assign(to: &$_passwordError)
    }
    
    // MARK: - Outputs
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var passwordError: AnyPublisher<String?, Never> {
        $_passwordError.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isEmailValid = $_emailError.map { $0 == nil }
        let isPasswordValid = $_passwordError.map { $0 == nil }
        
        return Publishers.CombineLatest(isEmailValid, isPasswordValid)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }
    
    /// Если в твоём протоколе этого нет — просто удали блок целиком.
    var refreshId: AnyPublisher<UUID, Never> {
        $_refreshId.eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setEmail(_ value: String) { email = value }
    func setPassword(_ value: String) { password = value }
    
    // MARK: - Actions
    
    func signIn() async throws {
        guard validator.validate(email, for: .email).isValid,
              validator.validate(password, for: .password).isValid else {
            return
        }
        
        // 1) Логин
        try await authService.signIn(email: email, password: password)
        
        // 2) После логина uid уже должен быть доступен (в твоём AuthService он выставляется при подтверждённой почте)
        guard let uid = authService.currentUserId, !uid.isEmpty else {
            await MainActor.run { self._refreshId = UUID() }
            return
        }
        
        // 3) Variant A: профиль создан триггером в БД — делаем refresh -> local upsert
        do {
            let repo = makeProfileRepository(uid)
            try await repo.refresh(uid: uid)
        } catch {
            print("⚠️ SignInViewModel: profile refresh failed: \(error)")
        }
        
        // 4) Триггерим рефреш для UI/потоков (если используется)
        await MainActor.run { self._refreshId = UUID() }
    }
}
