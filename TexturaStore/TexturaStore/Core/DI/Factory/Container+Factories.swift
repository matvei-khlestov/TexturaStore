//
//  Container+Factories.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import FactoryKit

extension Container {
    
    // MARK: - Screen Factories
    
    var authScreenFactory: Factory<AuthScreenBuilding> {
        Factory(self) { @MainActor in
            AuthScreenFactory(
                signInViewModel: self.signInViewModel(),
                signUpViewModel: self.signUpViewModel()
            )
        }
        .scope(.singleton)
    }
}
