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

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - State

    @Published var selectedTab: MainTab = .catalog

    // MARK: - Callbacks

    var onLogout: (() -> Void)?

    // MARK: - Dependencies

    private let catalogCoordinator: any CatalogCoordinating
    private let favoritesCoordinator: any FavoritesCoordinating
    private let cartCoordinator: any CartCoordinating
    private let profileCoordinator: any ProfileCoordinating

    // MARK: - Init

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

    // MARK: - Coordinator Lifecycle

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

    // MARK: - Root View

    var rootView: AnyView {
        AnyView(
            TabView(selection: selectionBinding) {

                catalogCoordinator.rootView
                    .tabItem { Label("Каталог", systemImage: "square.grid.2x2") }
                    .tag(MainTab.catalog)

                favoritesCoordinator.rootView
                    .tabItem { Label("Избранное", systemImage: "heart") }
                    .tag(MainTab.favorites)

                cartCoordinator.rootView
                    .tabItem { Label("Корзина", systemImage: "cart") }
                    .tag(MainTab.cart)

                profileCoordinator.rootView
                    .tabItem { Label("Профиль", systemImage: "person") }
                    .tag(MainTab.profile)
            }
            .tint(.brandPrimary)
        )
    }

    private var selectionBinding: Binding<MainTab> {
        Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )
    }
}
