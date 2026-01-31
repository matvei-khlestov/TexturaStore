//
//  MainTabCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class MainTabCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - State

    @Published var selectedTab: MainTab = .catalog

    // MARK: - Callbacks

    var onLogout: (() -> Void)?

    // MARK: - Coordinator Lifecycle

    func start() {
        selectedTab = .catalog
    }

    func finish() {
        selectedTab = .catalog
        removeAllChildren()
    }

    // MARK: - Root View

    var rootView: some View {
        TabView(selection: selectionBinding) {

            AppNavigationContainer {
                Text("Каталог")
                    .navigationTitle("Каталог")
            }
            .tabItem { Label("Каталог", systemImage: "square.grid.2x2") }
            .tag(MainTab.catalog)

            AppNavigationContainer {
                Text("Избранное")
                    .navigationTitle("Избранное")
            }
            .tabItem { Label("Избранное", systemImage: "heart") }
            .tag(MainTab.favorites)

            AppNavigationContainer {
                Text("Корзина")
                    .navigationTitle("Корзина")
            }
            .tabItem { Label("Корзина", systemImage: "cart") }
            .tag(MainTab.cart)

            AppNavigationContainer {
                ProfileRootView(
                    onLogout: { [weak self] in
                        self?.onLogout?()
                    }
                )
            }
            .tabItem { Label("Профиль", systemImage: "person") }
            .tag(MainTab.profile)
        }
        .tint(.brandPrimary)
    }

    private var selectionBinding: Binding<MainTab> {
        Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )
    }
}
