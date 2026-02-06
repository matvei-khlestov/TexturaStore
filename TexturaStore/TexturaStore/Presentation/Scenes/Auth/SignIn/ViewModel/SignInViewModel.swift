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
/// - активацию кнопки входа при корректных данных.
///
/// Архитектура и зависимости:
/// - Использует `FormValidatingProtocol` для проверки корректности данных;
/// - Выполняет авторизацию через `AuthServiceProtocol`;
/// - Реализует реактивные паблишеры ошибок и состояния сабмита.
///
/// Особенности:
/// - Автоматическая проверка данных при изменении полей ввода;
/// - Combine-пайплайн активирует кнопку «Войти» при валидных данных;
/// - Метод `signIn()` выполняет финальную валидацию и вход.
final class SignInViewModel: SignInViewModelProtocol, ObservableObject {
    
    // MARK: - Dependencies
    
    private let validator: FormValidatingProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - State
    
    @Published private var email: String = ""
    @Published private var password: String = ""
    
    @Published private var _emailError: String? = nil
    @Published private var _passwordError: String? = nil
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        validator: FormValidatingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.validator = validator
        self.authService = authService
        
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
    
    // MARK: - Inputs
    
    func setEmail(_ value: String) {
        email = value
    }
    
    func setPassword(_ value: String) {
        password = value
    }
    
    // MARK: - Actions
    
    func signIn() async throws {
        guard validator.validate(email, for: .email).isValid,
              validator.validate(password, for: .password).isValid else {
            return
        }
        
        try await authService.signIn(email: email, password: password)
    }
}
