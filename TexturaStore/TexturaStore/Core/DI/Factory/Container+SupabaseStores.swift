//
//  Container+SupabaseStores.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import FactoryKit
import Supabase

extension Container {
    
    // MARK: - Profile
    
    var profileStore: Factory<any ProfileStoreProtocol> {
        Factory(self) { @MainActor in
            SupabaseProfileStore(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Catalog
    
    var catalogStore: Factory<any CatalogStoreProtocol> {
        Factory(self) { @MainActor in
            SupabaseCatalogStore(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Cart
    
    var cartStore: Factory<any CartStoreProtocol> {
        Factory(self) { @MainActor in
            SupabaseCartStore(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Favorites
    
    var favoritesStore: Factory<any FavoritesStoreProtocol> {
        Factory(self) { @MainActor in
            SupabaseFavoritesStore(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Orders
    
    var ordersStore: Factory<any OrdersStoreProtocol> {
        Factory(self) { @MainActor in
            SupabaseOrdersStore(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
    
    // MARK: - Reviews
    
    var reviewsStore: Factory<any ReviewsStoreProtocol> {
        Factory(self) { @MainActor in
            SupabaseReviewsStore(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
}
