//
//  AuthSessionStoringProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 06.02.2026.
//

import Foundation

/// Протокол `AuthSessionStoringProtocol`
///
/// Определяет контракт для хранения и управления данными пользовательской сессии.
///
/// Основные задачи:
/// - сохранение данных активной сессии после успешного входа;
/// - восстановление сохранённой сессии при запуске приложения;
/// - очистка данных при выходе пользователя.
///
/// Используется в:
/// - `SupabaseAuthService` для управления состоянием авторизации;
/// - (опционально) `SessionManager` для восстановления текущего пользователя.
protocol AuthSessionStoringProtocol: AnyObject {
    
    /// Идентификатор текущего пользователя, если сессия сохранена.
    var userId: String? { get }
    
    /// Провайдер авторизации (например, `"email"` или `"apple"`).
    var authProvider: String? { get }
    
    /// Access token (если сохранён).
    var accessToken: String? { get }
    
    /// Refresh token (если сохранён).
    var refreshToken: String? { get }
    
    /// Сохраняет данные активной сессии.
    /// - Parameters:
    ///   - userId: Уникальный идентификатор пользователя.
    ///   - provider: Тип авторизационного провайдера.
    ///   - accessToken: access token Supabase.
    ///   - refreshToken: refresh token Supabase.
    func saveSession(
        userId: String,
        provider: String,
        accessToken: String,
        refreshToken: String
    )
    
    /// Очищает данные сессии при выходе пользователя.
    func clearSession()
}
