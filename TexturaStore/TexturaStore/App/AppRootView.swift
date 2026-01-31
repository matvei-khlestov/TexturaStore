//
//  AppRootView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI

struct AppRootView: View {
    
    @StateObject private var coordinator: AppCoordinator
    
    init() {
        let auth = AuthCoordinator()
        let main = MainTabCoordinator()
        let app = AppCoordinator(authCoordinator: auth, mainTabCoordinator: main)
        _coordinator = StateObject(wrappedValue: app)
    }
    
    var body: some View {
        coordinator.rootView
            .onAppear {
                coordinator.start()
            }
    }
}
