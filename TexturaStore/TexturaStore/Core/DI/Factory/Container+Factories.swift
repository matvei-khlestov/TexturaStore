//
//  Container+Factories.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import FactoryKit

extension Container {
    
    // MARK: - Auth
    
    var authScreenFactory: Factory<any AuthScreenBuilding> {
        Factory(self) { @MainActor in
            AuthScreenFactory(
                signInViewModel: self.signInViewModel(),
                signUpViewModel: self.signUpViewModel()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Legal / Common
    
    var privacyPolicyScreenFactory: Factory<any PrivacyPolicyScreenBuilding> {
        Factory(self) { @MainActor in
            PrivacyPolicyScreenFactory()
        }
        .scope(.singleton)
    }
    
    // MARK: - Profile
    
    var profileScreenFactory: Factory<any ProfileScreenBuilding> {
        Factory(self) { @MainActor in
            ProfileScreenFactory()
        }
        .scope(.singleton)
    }
}
