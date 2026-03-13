//
//  Container+CoreDataStores.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation
import FactoryKit
import CoreData

extension Container {
    
    // MARK: - Core Data
    
    /// Core Data стек приложения.
    ///
    /// Используется как единый источник `NSPersistentContainer` для всех локальных Core Data store.
    /// Важно: контейнер должен быть один на всё приложение.
    var coreDataStack: Factory<CoreDataStack> {
        Factory(self) { @MainActor in
            CoreDataStack.shared
        }
        .scope(.singleton)
    }
    
    /// Главный `NSPersistentContainer` приложения.
    /// Удобная фабрика, чтобы инжектить контейнер в `BaseCoreDataStore`-наследников.
    var coreDataContainer: Factory<NSPersistentContainer> {
        Factory(self) {
            self.coreDataStack().container
        }
        .scope(.singleton)
    }
    
    var profileLocalStore: Factory<any ProfileLocalStore> {
        Factory(self) { @MainActor in
            CoreDataProfileStore(container: self.coreDataContainer())
        }
        .scope(.singleton)
    }
    
    var catalogLocalStore: Factory<any CatalogLocalStore> {
        Factory(self) { @MainActor in
            CoreDataCatalogStore(container: self.coreDataContainer())
        }
        .scope(.singleton)
    }
    
    // MARK: - Cart
    
    var cartLocalStore: Factory<any CartLocalStore> {
        Factory(self) { @MainActor in
            CoreDataCartStore(container: self.coreDataContainer())
        }
        .scope(.singleton)
    }
    
    // MARK: - Favorites
    
    var favoritesLocalStore: Factory<any FavoritesLocalStore> {
        Factory(self) { @MainActor in
            CoreDataFavoritesStore(container: self.coreDataContainer())
        }
        .scope(.singleton)
    }
    
    // MARK: - Orders
    
    var ordersLocalStore: Factory<any OrdersLocalStore> {
        Factory(self) { @MainActor in
            CoreDataOrdersStore(container: self.coreDataContainer())
        }
        .scope(.singleton)
    }
    
    // MARK: - Reviews
    
    var reviewsLocalStore: Factory<any ReviewsLocalStore> {
        Factory(self) { @MainActor in
            CoreDataReviewsStore(container: self.coreDataContainer())
        }
        .scope(.singleton)
    }
}
