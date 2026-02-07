//
//  Container+Storages.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 06.02.2026.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Storages
    
    var authSessionStorage: Factory<any AuthSessionStoringProtocol> {
        Factory(self) { @MainActor in
            AuthSessionStorage(
                keychain: self.keychainService()
            )
        }
        .scope(.singleton)
    }
}
