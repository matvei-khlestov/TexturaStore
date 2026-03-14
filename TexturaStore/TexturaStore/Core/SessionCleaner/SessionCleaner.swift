//
//  SessionCleaner.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation

/// Реализация сервиса очистки пользовательской сессии.
///
/// Что очищает:
/// - `AuthSessionStoringProtocol` — access/refresh token, userId и provider;
/// - `CheckoutStoringProtocol` — сохранённые промежуточные данные оформления заказа;
/// - `ProfileLocalStore` — локальный профиль пользователя;
/// - `CartLocalStore` — локальную корзину пользователя;
/// - `FavoritesLocalStore` — локальное избранное пользователя;
/// - `OrdersLocalStore` — локальные заказы пользователя;
/// - `SettingsStorageProtocol` — пользовательские настройки (опционально).
///
/// Не очищает:
/// - системные данные приложения;
/// - внутренние конфигурации приложения.
///
/// Используется при:
/// - logout;
/// - delete account;
/// - полном сбросе пользовательской сессии.
final class SessionCleaner: SessionCleaning {
    
    // MARK: - Dependencies
    
    private let authSessionStorage: AuthSessionStoringProtocol
    private let checkoutStorage: CheckoutStoringProtocol
    private let settingsStorage: SettingsStorageProtocol
    
    private let profileStore: ProfileLocalStore
    private let cartStore: CartLocalStore
    private let favoritesStore: FavoritesLocalStore
    private let ordersStore: OrdersLocalStore
    
    // MARK: - Init
    
    init(
        authSessionStorage: AuthSessionStoringProtocol,
        checkoutStorage: CheckoutStoringProtocol,
        settingsStorage: SettingsStorageProtocol,
        profileStore: ProfileLocalStore,
        cartStore: CartLocalStore,
        favoritesStore: FavoritesLocalStore,
        ordersStore: OrdersLocalStore
    ) {
        self.authSessionStorage = authSessionStorage
        self.checkoutStorage = checkoutStorage
        self.settingsStorage = settingsStorage
        self.profileStore = profileStore
        self.cartStore = cartStore
        self.favoritesStore = favoritesStore
        self.ordersStore = ordersStore
    }
    
    // MARK: - SessionCleaning
    
    func clearSession(for userId: String?) {
        
        if let userId, !userId.isEmpty {
            
            profileStore.clear(userId: userId)
            cartStore.clear(userId: userId)
            favoritesStore.clear(userId: userId)
            ordersStore.clear(userId: userId)
        }
        
        authSessionStorage.clearSession()
        checkoutStorage.reset()
        settingsStorage.reset()
    }
}
