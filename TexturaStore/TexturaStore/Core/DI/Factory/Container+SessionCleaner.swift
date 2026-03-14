//
//  Container+SessionCleaner.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Session Cleaner
    
    var sessionCleaner: Factory<any SessionCleaning> {
        Factory(self) { @MainActor in
            SessionCleaner(
                authSessionStorage: self.authSessionStorage(),
                checkoutStorage: self.checkoutStorage(),
                settingsStorage: self.settingsStorage(),
                profileStore: self.profileLocalStore(),
                cartStore: self.cartLocalStore(),
                favoritesStore: self.favoritesLocalStore(),
                ordersStore: self.ordersLocalStore()
            )
        }
        .scope(.singleton)
    }
}
