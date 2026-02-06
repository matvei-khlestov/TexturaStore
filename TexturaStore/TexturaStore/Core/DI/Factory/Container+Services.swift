//
//  Container+Services.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 04.02.2026.
//

import Foundation
import FactoryKit
import Supabase

extension Container {
    
    // MARK: - Keychain
    
    var keychainService: Factory<KeychainServiceProtocol> {
        Factory(self) { @MainActor in
            KeychainService(
                service: Bundle.main.bundleIdentifier ?? "TexturaStore",
                accessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Auth
    
    var authService: Factory<AuthServiceProtocol> {
        Factory(self) { @MainActor in
            SupabaseAuthService(
                supabase: self.supabaseClient(),
                session: self.authSessionStorage()
            )
        }
        .scope(.singleton)
    }
}
