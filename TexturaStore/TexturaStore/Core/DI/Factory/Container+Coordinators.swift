//
//  Container+Coordinators.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import FactoryKit

extension Container {
    
    // MARK: - Tabs
    
    var catalogCoordinator: Factory<any CatalogCoordinating> {
        Factory(self) { @MainActor in
            CatalogCoordinator()
        }
        .scope(.singleton)
    }
    
    var favoritesCoordinator: Factory<any FavoritesCoordinating> {
        Factory(self) { @MainActor in
            FavoritesCoordinator()
        }
        .scope(.singleton)
    }
    
    var cartCoordinator: Factory<any CartCoordinating> {
        Factory(self) { @MainActor in
            CartCoordinator()
        }
        .scope(.singleton)
    }
    
    var profileCoordinator: Factory<any ProfileCoordinating> {
        Factory(self) { @MainActor in
            ProfileCoordinator()
        }
        .scope(.singleton)
    }
    
    // MARK: - Auth
    
    var authCoordinator: Factory<any AuthCoordinating> {
        Factory(self) { @MainActor in
            AuthCoordinator(
                screenFactory: self.authScreenFactory()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - MainTab
    
    var mainTabCoordinator: Factory<any MainTabCoordinating> {
        Factory(self) { @MainActor in
            MainTabCoordinator(
                catalogCoordinator: self.catalogCoordinator(),
                favoritesCoordinator: self.favoritesCoordinator(),
                cartCoordinator: self.cartCoordinator(),
                profileCoordinator: self.profileCoordinator()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - App
    
    var appCoordinator: Factory<any AppCoordinating> {
        Factory(self) { @MainActor in
            AppCoordinator(
                authCoordinator: self.authCoordinator(),
                mainTabCoordinator: self.mainTabCoordinator()
            )
        }
        .scope(.singleton)
    }
}
