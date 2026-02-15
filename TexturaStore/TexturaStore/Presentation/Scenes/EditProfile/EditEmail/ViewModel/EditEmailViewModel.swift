//
//  EditEmailViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import Foundation
import Combine

/// ViewModel `EditEmailViewModel` для экрана смены e-mail пользователя.
///
/// Основные задачи:
/// - Валидация введённого e-mail с помощью `FormValidatingProtocol`;
/// - Загрузка текущего профиля через `ProfileRepository`;
/// - Управление состоянием кнопки "Сохранить" на основе валидности и изменений;
/// - Запуск смены e-mail через Supabase Auth (`requestEmailChange`) с отправкой письма подтверждения;
/// - (Опционально) последующая синхронизация `profiles.email` может быть выполнена после подтверждения
///   (в приложении при следующем refresh/логине) через `syncEmailFromAuth(uid:)`.
///
/// Обеспечивает реактивное обновление интерфейса через Combine,
/// синхронизируя текущее состояние формы и ошибки валидации в реальном времени.

final class EditEmailViewModel: ObservableObject, EditEmailViewModelProtocol {
    
    // MARK: - Deps
    
    private let userId: String
    private let validator: FormValidatingProtocol
    private let profileRepository: ProfileRepository
    
    // MARK: - State
    
    @Published private var email: String = ""
    @Published private var _emailError: String? = nil
    
    private var initialEmail: String = ""
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        profileRepository: ProfileRepository,
        userId: String,
        validator: FormValidatingProtocol
    ) {
        self.profileRepository = profileRepository
        self.userId = userId
        self.validator = validator
        
        bindProfile()
    }
    
    // MARK: - Outputs
    
    var currentEmail: String { email }
    var currentError: String? { _emailError }
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var emailPublisher: AnyPublisher<String, Never> {
        $email.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_emailError.map { $0 == nil }
        
        let isChanged = $email
            .map { [weak self] new in
                guard let self else { return false }
                let a = new.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let b = self.initialEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return !a.isEmpty && a != b
            }
        
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setEmail(_ value: String) {
        email = value
    }
    
    // MARK: - Actions
    
    func submit() async throws {
        guard validator.validate(email, for: .email).isValid else { return }
        
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Запускаем корректную смену e-mail через Supabase Auth (письмо подтверждения).
        try await profileRepository.requestEmailChange(email: trimmed)
        
        await MainActor.run {
            // UI-логика: фиксируем введённое значение, чтобы кнопка выключилась после запроса.
            // Фактическое значение `profiles.email` обновится после подтверждения и синка.
            self.initialEmail = trimmed
            self.email = trimmed
        }
    }
    
    private func bindProfile() {
        profileRepository.observeProfile()
            .compactMap { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.initialEmail = profile.email
                self.email = profile.email
            }
            .store(in: &bag)
        
        $email
            .removeDuplicates()
            .map { [validator] in validator.validate($0, for: .email).message }
            .assign(to: &$_emailError)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditEmailViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentEmail }
    var error: AnyPublisher<String?, Never> { emailError }
    func setValue(_ value: String) { setEmail(value) }
}
