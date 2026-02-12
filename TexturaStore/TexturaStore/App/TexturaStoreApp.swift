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

    private let coreData = CoreDataStack.shared

    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var settingsService = Container.shared.settingsService()

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: makeAppCoordinator())
                .environment(\.managedObjectContext, coreData.container.viewContext)
                .environmentObject(localization)
                .environmentObject(settingsService)
                .environment(\.locale, localization.locale)
                .preferredColorScheme(settingsService.preferredColorScheme)
                // ✅ Вот “перезагрузка приложения” после смены языка
                .id(localization.reloadToken)
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
