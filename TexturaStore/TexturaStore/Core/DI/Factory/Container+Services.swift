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
    
    var keychainService: Factory<any KeychainServiceProtocol> {
        Factory(self) { @MainActor in
            KeychainService(
                service: Bundle.main.bundleIdentifier ?? "TexturaStore",
                accessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Auth
    
    var authService: Factory<any AuthServiceProtocol> {
        Factory(self) { @MainActor in
            SupabaseAuthService(
                supabase: self.supabaseClient(),
                session: self.authSessionStorage()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Password Reset
    
    var passwordResetService: Factory<any PasswordResetServiceProtocol> {
        Factory(self) { @MainActor in
            SupabasePasswordResetService(
                supabase: self.supabaseClient(),
                redirectURL: URL(string: "https://auth.texturastore.tech")
            )
        }
        .scope(.singleton)
    }
    
    var avatarStorageService: Factory<AvatarStorageServiceProtocol> {
        Factory(self) { @MainActor in
            AvatarStorageService()
        }
        .scope(.singleton)
    }
    
    // MARK: - Settings
    
    var settingsService: Factory<SettingsService> {
        Factory(self) { @MainActor in
            SettingsService(
                storage: self.settingsStorage(),
                localization: self.localizationManager()
            )
        }
        .scope(.singleton)
    }
    
    var settingsServiceProtocol: Factory<any SettingsServiceProtocol> {
        Factory(self) { @MainActor in
            self.settingsService()
        }
    }
}
