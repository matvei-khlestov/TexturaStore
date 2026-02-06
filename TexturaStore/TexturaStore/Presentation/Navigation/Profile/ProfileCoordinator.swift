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
    
    // MARK: - Dependencies
    
    private let profileScreenFactory: ProfileScreenBuilding
    private let profileViewModel: ProfileViewModelProtocol
    
    // MARK: - Init
    
    init(
        profileScreenFactory: ProfileScreenBuilding,
        profileViewModel: ProfileViewModelProtocol
    ) {
        self.profileScreenFactory = profileScreenFactory
        self.profileViewModel = profileViewModel
    }
    
    // MARK: - Coordinator Lifecycle
    
    func start() { }
    
    func finish() {
        removeAllChildren()
    }
    
    // MARK: - Root View
    
    var rootView: AnyView {
        profileScreenFactory.makeProfileRootView(
            viewModel: profileViewModel,
            onLogout: { [weak self] in
                self?.onLogout?()
            }
        )
    }
}
