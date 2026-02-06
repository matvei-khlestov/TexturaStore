//
//  SignUpViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import Foundation
import Combine

/// ViewModel `SignUpViewModel` для экрана регистрации.
///
/// Отвечает за:
/// - обработку и валидацию пользовательского ввода (имя, e-mail, пароль);
/// - проверку согласия с политикой конфиденциальности;
/// - активацию кнопки "Зарегистрироваться" при корректных данных.
///
/// Архитектура и зависимости:
/// - Использует Combine для реактивной обработки ошибок валидации;
/// - Работает с `FormValidatingProtocol` для проверок формата данных;
/// - Выполняет регистрацию через `AuthServiceProtocol`.
///
/// Особенности:
/// - Автоматически обновляет ошибки при изменении значений полей;
/// - Паблишеры ошибок (`nameError`, `emailError`, `passwordError`, `agreementError`);
/// - Паблишер `isSubmitEnabled` активирует кнопку сабмита при валидных данных;
/// - Метод `signUp()` выполняет финальную валидацию и регистрацию.
final class SignUpViewModel: SignUpViewModelProtocol, ObservableObject {
    
    // MARK: - Dependencies
    
    private let validator: FormValidatingProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - State
    
    @Published private var name: String = ""
    @Published private var email: String = ""
    @Published private var password: String = ""
    @Published private var agreed: Bool = false
    
    @Published private var _nameError: String? = nil
    @Published private var _emailError: String? = nil
    @Published private var _passwordError: String? = nil
    @Published private var _agreementError: String? = nil
    
    private let signUpSuccessSubject = PassthroughSubject<Void, Never>()
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        validator: FormValidatingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.validator = validator
        self.authService = authService
        
        $name
            .map { [validator] in
                validator.validate($0, for: .name).message
            }
            .assign(to: &$_nameError)
        
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
        
        $agreed
            .map { $0 ? nil : L10n.Auth.Signup.Agreement.error }
            .assign(to: &$_agreementError)
    }
    
    // MARK: - Outputs
    
    var nameError: AnyPublisher<String?, Never> {
        $_nameError.eraseToAnyPublisher()
    }
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var passwordError: AnyPublisher<String?, Never> {
        $_passwordError.eraseToAnyPublisher()
    }
    
    var agreementError: AnyPublisher<String?, Never> {
        $_agreementError.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(
            $_nameError.map { $0 == nil },
            $_emailError.map { $0 == nil },
            $_passwordError.map { $0 == nil },
            $_agreementError.map { $0 == nil }
        )
        .map { $0 && $1 && $2 && $3 }
        .eraseToAnyPublisher()
    }
    
    var signUpSuccess: AnyPublisher<Void, Never> {
        signUpSuccessSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setName(_ v: String) { name = v }
    func setEmail(_ v: String) { email = v }
    func setPassword(_ v: String) { password = v }
    func setAgreement(_ v: Bool) { agreed = v }
    
    // MARK: - Actions
    
    func signUp() async throws {
        guard validator.validate(name, for: .name).isValid,
              validator.validate(email, for: .email).isValid,
              validator.validate(password, for: .password).isValid,
              agreed else { return }
        
        try await authService.signUp(email: email, password: password)
        
        signUpSuccessSubject.send(())
    }
}
