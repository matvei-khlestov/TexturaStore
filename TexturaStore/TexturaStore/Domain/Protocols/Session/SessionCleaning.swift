//
//  SessionCleaning.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation

/// Сервис очистки пользовательской сессии и связанных локальных данных.
///
/// Назначение:
/// - централизованно очищает данные текущего пользователя при logout/delete account;
/// - удаляет auth-сессию, локальные checkout-данные и пользовательские кэши;
/// - очищает локальные CoreData сторы пользователя;
/// - предотвращает размазывание логики очистки по `AuthService`, `Coordinator` и `Repository`.
///
/// Используется в:
/// - `SupabaseAuthService` — после выхода из аккаунта;
/// - `SupabaseAuthService` — после удаления аккаунта;
/// - других сценариях полного сброса пользовательского состояния.
protocol SessionCleaning: AnyObject {
    
    /// Очистка пользовательской сессии.
    ///
    /// - Parameter userId: идентификатор пользователя для очистки локальных данных.
    func clearSession(for userId: String?)
}
