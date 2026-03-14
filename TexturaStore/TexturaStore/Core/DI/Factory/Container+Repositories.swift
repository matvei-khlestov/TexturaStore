//
//  Container+Repositories.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Profile Repository Factory
    
    var makeProfileRepository: (String) -> ProfileRepository {
        { userId in
            DefaultProfileRepository(
                remote: self.profileStore(),
                local: self.profileLocalStore(),
                userId: userId
            )
        }
    }
    
    // MARK: - Catalog Repository
    
    var catalogRepository: Factory<any CatalogRepository> {
        Factory(self) { @MainActor in
            DefaultCatalogRepository(
                remote: self.catalogStore(),
                local: self.catalogLocalStore()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Cart Repository Factory
    
    /// Создаёт CartRepository под конкретного пользователя.
    var makeCartRepository: (String) -> CartRepository {
        { userId in
            DefaultCartRepository(
                remote: self.cartStore(),
                local: self.cartLocalStore(),
                catalog: self.catalogLocalStore(),
                userId: userId
            )
        }
    }
    
    // MARK: - Favorites Repository Factory
    
    /// Создаёт FavoritesRepository под конкретного пользователя.
    var makeFavoritesRepository: (String) -> FavoritesRepository {
        { userId in
            DefaultFavoritesRepository(
                remote: self.favoritesStore(),
                local: self.favoritesLocalStore(),
                catalog: self.catalogLocalStore(),
                userId: userId
            )
        }
    }
    
    // MARK: - Orders Repository Factory
    
    /// Создаёт OrdersRepository под конкретного пользователя.
    var makeOrdersRepository: (String) -> OrdersRepository {
        { userId in
            DefaultOrdersRepository(
                remote: self.ordersStore(),
                local: self.ordersLocalStore(),
                userId: userId
            )
        }
    }
    
    // MARK: - Reviews Repository Factory
    
    /// Создаёт ReviewsRepository под конкретный товар.
    var makeReviewsRepository: (String) -> ReviewsRepository {
        { productId in
            DefaultReviewsRepository(
                remote: self.reviewsStore(),
                local: self.reviewsLocalStore(),
                productId: productId
            )
        }
    }
}
