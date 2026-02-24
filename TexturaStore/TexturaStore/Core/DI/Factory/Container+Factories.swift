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
    
    // MARK: - Boot
    
    var bootScreenFactory: Factory<any BootScreenBuilding> {
        Factory(self) { @MainActor in
            BootScreenFactory()
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
    
    var profileEditScreenFactory: Factory<any ProfileEditScreenBuilding> {
        Factory(self) { @MainActor in
            ProfileEditScreenFactory()
        }
        .scope(.singleton)
    }
    
    // MARK: - Catalog
    
    var catalogScreenFactory: Factory<any CatalogScreenBuilding> {
        Factory(self) { @MainActor in
            CatalogScreenFactory()
        }
        .scope(.singleton)
    }
    
    // MARK: - Category Products
    
    var categoryProductsScreenFactory: Factory<any CategoryProductsScreenBuilding> {
        Factory(self) { @MainActor in
            CategoryProductsScreenFactory()
        }
        .scope(.singleton)
    }
    
    // MARK: - Product Details
    
    var productDetailsScreenFactory: Factory<any ProductDetailsScreenBuilding> {
        Factory(self) { @MainActor in
            ProductDetailsScreenFactory()
        }
        .scope(.singleton)
    }
    
    // MARK: - Favorites
    
    var favoritesScreenFactory: Factory<any FavoritesScreenBuilding> {
        Factory(self) { @MainActor in
            FavoritesScreenFactory()
        }
        .scope(.singleton)
    }
    
    // MARK: - Cart
    
    var cartScreenFactory: Factory<any CartScreenBuilding> {
        Factory(self) { @MainActor in
            CartScreenFactory()
        }
        .scope(.singleton)
    }
}
