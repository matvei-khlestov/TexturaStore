//
//  MainTabCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class MainTabCoordinator: MainTabCoordinating {
    
    var childCoordinators: [any CoordinatorBox] = []
    
    @Published var selectedTab: MainTab = .catalog
    
    var onLogout: (() -> Void)?
    
    private let catalogCoordinator: any CatalogCoordinating
    private let favoritesCoordinator: any FavoritesCoordinating
    private let cartCoordinator: any CartCoordinating
    private let profileCoordinator: any ProfileCoordinating
    
    init(
        catalogCoordinator: any CatalogCoordinating,
        favoritesCoordinator: any FavoritesCoordinating,
        cartCoordinator: any CartCoordinating,
        profileCoordinator: any ProfileCoordinating
    ) {
        self.catalogCoordinator = catalogCoordinator
        self.favoritesCoordinator = favoritesCoordinator
        self.cartCoordinator = cartCoordinator
        self.profileCoordinator = profileCoordinator
        
        storeChild(catalogCoordinator)
        storeChild(favoritesCoordinator)
        storeChild(cartCoordinator)
        storeChild(profileCoordinator)
        
        self.profileCoordinator.onLogout = { [weak self] in
            self?.onLogout?()
        }
    }
    
    func start() {
        selectedTab = .catalog
        catalogCoordinator.start()
        favoritesCoordinator.start()
        cartCoordinator.start()
        profileCoordinator.start()
    }
    
    func finish() {
        selectedTab = .catalog
        removeAllChildren()
    }
    
    var rootView: AnyView {
        AnyView(
            MainTabRootView(
                selectedTab: selectionBinding,
                catalogRoot: catalogCoordinator.rootView,
                favoritesRoot: favoritesCoordinator.rootView,
                cartRoot: cartCoordinator.rootView,
                profileRoot: profileCoordinator.rootView
            )
        )
    }
    
    private var selectionBinding: Binding<MainTab> {
        Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )
    }
}
