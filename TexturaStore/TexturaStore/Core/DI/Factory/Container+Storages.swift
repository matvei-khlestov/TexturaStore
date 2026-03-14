//
//  Container+Storages.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 06.02.2026.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Auth
    
    var authSessionStorage: Factory<any AuthSessionStoringProtocol> {
        Factory(self) { @MainActor in
            AuthSessionStorage(
                keychain: self.keychainService()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Settings
    
    var settingsStorage: Factory<SettingsStorageProtocol> {
        Factory(self) { @MainActor in
            SettingsStorage()
        }
        .scope(.singleton)
    }
    
    // MARK: - Checkout
    
    var checkoutStorage: Factory<any CheckoutStoringProtocol> {
        Factory(self) { @MainActor in
            CheckoutStorage.shared
        }
        .scope(.singleton)
    }
}
