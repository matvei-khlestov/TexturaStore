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
                authService: self.authService()
            )
        }
        .scope(.singleton)
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
                validator: self.formValidator()
            )
        }
        .scope(.shared)
    }
    
    // MARK: - Profile
    
    var profileViewModel: Factory<any ProfileViewModelProtocol> {
        Factory(self) { @MainActor in
            ProfileViewModel(
                authService: self.authService()
            )
        }
        .scope(.shared)
    }
}
