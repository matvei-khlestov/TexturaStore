//
//  CatalogCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
final class CatalogCoordinator: CatalogCoordinating {
    
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
            Text("Каталог")
                .navigationTitle("Каталог")
            
        )
    }
}
