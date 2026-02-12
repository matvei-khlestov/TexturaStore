//
//  Container+ViewModels.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import FactoryKit

extension Container {
    
    // MARK: - Auth
    
    var signInViewModel: Factory<any SignInViewModelProtocol> {
        Factory(self) { @MainActor in
            SignInViewModel(
                validator: self.formValidator(),
                authService: self.authService(),
                makeProfileRepository: self.makeProfileRepository
            )
        }
        .scope(.shared)
    }
    
    var signUpViewModel: Factory<any SignUpViewModelProtocol> {
        Factory(self) { @MainActor in
            SignUpViewModel(
                validator: self.formValidator(),
                authService: self.authService()
            )
        }
        .scope(.singleton)
    }
    
    var resetPasswordViewModel: Factory<any ResetPasswordViewModelProtocol> {
        Factory(self) { @MainActor in
            ResetPasswordViewModel(
                validator: self.formValidator(),
                passwordResetService: self.passwordResetService()
            )
        }
        .scope(.shared)
    }
    
    // MARK: - Profile
    
    var profileViewModel: Factory<(String) -> any ProfileUserViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                ProfileUserViewModel(
                    auth: self.authService(),
                    avatarStorage: self.avatarStorageService(),
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId
                )
            }
        }
    }
    
    // MARK: - Settings
    
    var settingsViewModel: Factory<any SettingsViewModelProtocol> {
        Factory(self) { @MainActor in
            SettingsViewModel(
                service: self.settingsService()
            )
        }
        .scope(.shared)
    }
}
