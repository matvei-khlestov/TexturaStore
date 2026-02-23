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
    
    var editProfileViewModel: Factory<(String) -> any EditProfileViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditProfileViewModel(
                    avatarStorage: self.avatarStorageService(),
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId
                )
            }
        }
        .scope(.shared)
    }
    
    var editNameViewModel: Factory<(String) -> any EditNameViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditNameViewModel(
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId,
                    validator: self.formValidator()
                )
            }
        }
        .scope(.shared)
    }
    
    var editEmailViewModel: Factory<(String) -> any EditEmailViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditEmailViewModel(
                    profileRepository: self.makeProfileRepository(userId),
                    userId: userId,
                    validator: self.formValidator()
                )
            }
        }
        .scope(.shared)
    }
    
    var editPhoneViewModel: Factory<(String) -> any EditPhoneViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                EditPhoneViewModel(
                    profileRepository: self.makeProfileRepository(userId),
                    validator: self.formValidator(),
                    userId: userId
                )
            }
        }
        .scope(.shared)
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
    
    // MARK: - Catalog
    
    var makeCatalogViewModel: Factory<(String) -> any CatalogViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                CatalogViewModel(
                    repository: self.catalogRepository(),
                    cartRepository: self.makeCartRepository(userId),
                    favoritesRepository: self.makeFavoritesRepository(userId),
                    priceFormatter: self.priceFormatter()
                )
            }
        }
    }
    
    // MARK: - Product details
    
    var makeProductDetailsViewModel: Factory<(String, String) -> any ProductDetailsViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId, productId in
                ProductDetailsViewModel(
                    productId: productId,
                    favoritesRepository: self.makeFavoritesRepository(userId),
                    cartRepository: self.makeCartRepository(userId),
                    catalogRepository: self.catalogRepository(),
                    priceFormatter: self.priceFormatter()
                )
            }
        }
    }
    
    // MARK: - Favorites
    
    var makeFavoritesViewModel: Factory<(String) -> any FavoritesViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                FavoritesViewModel(
                    favoritesRepository: self.makeFavoritesRepository(userId),
                    cartRepository: self.makeCartRepository(userId),
                    priceFormatter: self.priceFormatter(),
                    notificationService: self.localNotificationService()
                )
            }
        }
    }
    
    // MARK: - Cart
    
    var makeCartViewModel: Factory<(String) -> any CartViewModelProtocol> {
        Factory(self) { @MainActor in
            { userId in
                CartViewModel(
                    cartRepository: self.makeCartRepository(userId),
                    priceFormatter: self.priceFormatter(),
                    notificationService: self.localNotificationService()
                )
            }
        }
    }
}
