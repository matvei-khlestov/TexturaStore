//
//  EditEmailViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import Combine

/// Протокол ViewModel для экрана смены e-mail пользователя.
///
/// Отвечает за валидацию нового e-mail, запуск процесса смены почты через Supabase Auth
/// (с отправкой письма подтверждения), обработку ошибок и реактивное обновление
/// интерфейса при вводе данных.
///
/// Наследуется от `BaseEditFieldViewModelProtocol` для унификации поведения
/// экранов редактирования профиля.

protocol EditEmailViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    
    // MARK: - Outputs
    
    /// Текущее значение e-mail пользователя (в поле ввода).
    var currentEmail: String { get }
    
    /// Текущее сообщение об ошибке валидации / запроса.
    var currentError: String? { get }
    
    /// Паблишер ошибок e-mail.
    var emailError: AnyPublisher<String?, Never> { get }
    
    /// Паблишер значения e-mail.
    var emailPublisher: AnyPublisher<String, Never> { get }
    
    // MARK: - Inputs
    
    /// Устанавливает новое значение e-mail пользователя.
    func setEmail(_ value: String)
}
