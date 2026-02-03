//
//  ProfileCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
final class ProfileCoordinator: ProfileCoordinating {
    
    // MARK: - Coordinator
    
    var childCoordinators: [any CoordinatorBox] = []
    
    // MARK: - Callbacks
    
    var onLogout: (() -> Void)?
    
    // MARK: - Coordinator Lifecycle
    
    func start() { }
    
    func finish() {
        removeAllChildren()
    }
    
    // MARK: - Root View
    
    var rootView: AnyView {
        AnyView(
            ProfileRootView(
                onLogout: { [weak self] in
                    self?.onLogout?()
                }
            )
            
        )
    }
}
