//
//  FavoritesCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
final class FavoritesCoordinator: FavoritesCoordinating {
    
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
            Text("Избранное")
                .navigationTitle("Избранное")
            
        )
    }
}
