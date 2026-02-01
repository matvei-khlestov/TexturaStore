//
//  TexturaStoreApp.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import CoreData
import FactoryKit

@main
struct TexturaStoreApp: App {
    
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: makeAppCoordinator())
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
    }
    
    @MainActor
    private func makeAppCoordinator() -> AppCoordinator {
        guard let app = Container.shared.appCoordinator() as? AppCoordinator else {
            fatalError("Container.appCoordinator must return AppCoordinator")
        }
        return app
    }
}
