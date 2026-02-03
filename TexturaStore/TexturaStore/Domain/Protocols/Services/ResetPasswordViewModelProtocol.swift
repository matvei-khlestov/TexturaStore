//
//  ResetPasswordViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import Foundation
import Combine

/// Протокол `ResetPasswordViewModelProtocol` описывает интерфейс ViewModel
/// для экрана восстановления пароля.
///
/// Отвечает за:
/// - приём и валидацию e-mail пользователя;
/// - управление состоянием доступности кнопки восстановления;
/// - выполнение асинхронного сценария сброса пароля.
///
/// Основные задачи:
/// - обеспечивает реактивную проверку корректности e-mail;
/// - публикует ошибки и флаг активности кнопки через Combine.

protocol ResetPasswordViewModelProtocol: AnyObject {

    // MARK: - Inputs

    /// Устанавливает e-mail пользователя для восстановления пароля.
    func setEmail(_ value: String)

    // MARK: - Outputs

    /// Ошибка валидации e-mail.
    var emailError: AnyPublisher<String?, Never> { get }

    /// Флаг, разрешающий активацию кнопки восстановления пароля.
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }

    // MARK: - Actions

    /// Запускает сценарий восстановления пароля.
    func resetPassword() async throws
}
