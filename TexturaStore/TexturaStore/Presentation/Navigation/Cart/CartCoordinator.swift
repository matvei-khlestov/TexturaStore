//
//  CartCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
final class CartCoordinator: CartCoordinating {

    // MARK: - Coordinator

    var childCoordinators: [any CoordinatorBox] = []

    // MARK: - Coordinator Lifecycle

    func start() { }

    func finish() {
        removeAllChildren()
    }

    // MARK: - Root View

    var rootView: AnyView {
        AnyView(
            AppNavigationContainer {
                Text("Корзина")
                    .navigationTitle("Корзина")
            }
        )
    }
}
