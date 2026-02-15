//
//  Container+Navigators.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import FactoryKit

extension Container {
    
    // MARK: - Edit Profile
    
    var editProfileNavigator: Factory<any EditProfileNavigating> {
        Factory(self) { @MainActor in
            EditProfileNavigator(
                profileEditScreenFactory: self.profileEditScreenFactory(),
                authService: self.authService(),
                makeEditProfileViewModel: self.editProfileViewModel(),
                makeEditNameViewModel: self.editNameViewModel(),
                makeEditEmailViewModel: self.editEmailViewModel(),
                makeEditPhoneViewModel: self.editPhoneViewModel()
            )
        }
        .scope(.singleton)
    }
}
