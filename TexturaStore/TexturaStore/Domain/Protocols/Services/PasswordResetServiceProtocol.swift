//
//  PasswordResetServiceProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import Foundation

/// Протокол `PasswordResetServiceProtocol`.
///
/// Определяет интерфейс сервиса восстановления пароля для SwiftUI-приложения,
/// использующего Supabase Auth.
///
/// Отвечает за отправку письма со ссылкой на сброс пароля на указанный e-mail.
///
/// Основные задачи:
/// - инициирование сброса пароля через Supabase Auth (email reset flow);
/// - предоставление асинхронного API для безопасной обработки ошибок.
///
/// Используется в:
/// - `ResetPasswordViewModel`
///   для выполнения запроса восстановления пароля и уведомления пользователя о результате.
protocol PasswordResetServiceProtocol: AnyObject {

    /// Отправляет письмо для восстановления пароля на указанный e-mail.
    ///
    /// - Parameter email: Электронная почта пользователя, на которую будет отправлено письмо.
    /// - Throws: Ошибку, если адрес некорректен или произошёл сбой при отправке.
    ///
    /// - Note:
    /// Supabase (в типовой конфигурации) может возвращать успех даже если пользователя
    /// с таким email не существует — это защита от перебора/утечек (email enumeration).
    func sendPasswordReset(email: String) async throws
}
