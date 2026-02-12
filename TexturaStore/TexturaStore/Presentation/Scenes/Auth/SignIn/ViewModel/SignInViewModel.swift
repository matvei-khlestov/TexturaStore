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
/// - после входа выполняется `repo.refresh(uid:)`, чтобы подтянуть профиль в Core Data.
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
    
    // MARK: - Normalize
    
    private func normalizedUserId(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    // MARK: - Outputs
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var passwordError: AnyPublisher<String?, Never> {
        $_passwordError.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(
            $_emailError.map { $0 == nil },
            $_passwordError.map { $0 == nil }
        )
        .map { $0 && $1 }
        .eraseToAnyPublisher()
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
        
        // 2) После логина uid должен быть доступен (email подтверждён)
        guard let rawUid = authService.currentUserId, !rawUid.isEmpty else {
            return
        }
        
        let uid = normalizedUserId(rawUid)
        
        // 3) Variant A: профиль уже создан триггером в БД — подтягиваем в Core Data
        do {
            let repo = makeProfileRepository(uid)
            try await repo.refresh(uid: uid)
        } catch {
            print("⚠️ SignInViewModel: profile refresh failed: \(error)")
        }
    }
}
