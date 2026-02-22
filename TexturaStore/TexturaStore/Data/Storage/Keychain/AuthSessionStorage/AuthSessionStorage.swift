//
//  AuthSessionStorage.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 06.02.2026.
//

import Foundation

/// Класс `AuthSessionStorage`
///
/// Реализует протокол `AuthSessionStoringProtocol` и отвечает
/// за безопасное хранение данных сессии пользователя с помощью `KeychainServiceProtocol`.
///
/// Храним:
/// - userId
/// - authProvider
/// - accessToken
/// - refreshToken
final class AuthSessionStorage: AuthSessionStoringProtocol {
    
    private let keychain: any KeychainServiceProtocol
    
    init(keychain: any KeychainServiceProtocol) {
        self.keychain = keychain
    }
    
    // MARK: - Read
    
    var userId: String? {
        keychain.get(.userId)
    }
    
    var authProvider: String? {
        keychain.get(.authProvider)
    }
    
    var accessToken: String? {
        keychain.get(.accessToken)
    }
    
    var refreshToken: String? {
        keychain.get(.refreshToken)
    }
    
    // MARK: - Write
    
    func saveSession(
        userId: String,
        provider: String,
        accessToken: String,
        refreshToken: String
    ) {
        keychain.set(userId, for: .userId)
        keychain.set(provider, for: .authProvider)
        keychain.set(accessToken, for: .accessToken)
        keychain.set(refreshToken, for: .refreshToken)
    }
    
    func clearSession() {
        _ = keychain.remove(.userId)
        _ = keychain.remove(.authProvider)
        _ = keychain.remove(.accessToken)
        _ = keychain.remove(.refreshToken)
    }
}
