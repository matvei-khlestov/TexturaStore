//
//  ResetPasswordViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import Foundation
import Combine

/// ViewModel `ResetPasswordViewModel` для экрана восстановления пароля.
///
/// Отвечает за:
/// - обработку и валидацию введённого e-mail;
/// - управление состоянием кнопки отправки через Combine;
/// - запуск сценария сброса пароля.
///
/// Особенности:
/// - реактивно обновляет ошибки поля e-mail;
/// - нормализует e-mail перед использованием (обрезка пробелов, lowercase);
/// - предотвращает выполнение действия при невалидных данных.
@MainActor
final class ResetPasswordViewModel: ResetPasswordViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let validator: any FormValidatingProtocol
    private let passwordResetService: any PasswordResetServiceProtocol
    
    // MARK: - State
    
    @Published private var email: String = ""
    @Published private var _emailError: String? = nil
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        validator: any FormValidatingProtocol,
        passwordResetService: any PasswordResetServiceProtocol
    ) {
        self.validator = validator
        self.passwordResetService = passwordResetService
        
        $email
            .map { [validator] in
                validator.validate($0, for: .email).message
            }
            .assign(to: &$_emailError)
    }
    
    // MARK: - Outputs
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($_emailError, $email)
            .map { errorMessage, email in
                errorMessage == nil && !email.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setEmail(_ value: String) {
        email = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
    
    // MARK: - Actions
    
    func resetPassword() async throws {
        guard validator.validate(email, for: .email).isValid else { return }
        try await passwordResetService.sendPasswordReset(email: email)
    }
}
