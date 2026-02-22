//
//  TexturaStoreApp.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import CoreData
import FactoryKit
import UserNotifications

@main
struct TexturaStoreApp: App {

    private let coreData = CoreDataStack.shared

    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var settingsService = Container.shared.settingsService()

    @State private var didSetupNotifications = false

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: makeAppCoordinator())
                .environment(\.managedObjectContext, coreData.container.viewContext)
                .environmentObject(localization)
                .environmentObject(settingsService)
                .environment(\.locale, localization.locale)
                .preferredColorScheme(settingsService.preferredColorScheme)
                .id(localization.reloadToken)
                .onAppear {
                    setupNotificationsIfNeeded()
                }
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

// MARK: - Notifications

private extension TexturaStoreApp {

    func setupNotificationsIfNeeded() {
        guard !didSetupNotifications else { return }
        didSetupNotifications = true

        let notifications = LocalNotificationService.shared

        notifications.registerCategories([
            LocalNotificationFactory.favoritesCategory(),
            LocalNotificationFactory.cartCategory(),
            LocalNotificationFactory.checkoutCategory()
        ])

        notifications.getSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                notifications.requestAuthorization { granted in
                    #if DEBUG
                    print("🔔 Notifications granted:", granted)
                    #endif
                }
            default:
                break
            }
        }
    }
}
