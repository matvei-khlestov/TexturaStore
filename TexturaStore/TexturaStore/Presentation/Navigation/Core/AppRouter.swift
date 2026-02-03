//
//  AppRouter.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter<
    StackRoute: RouteIdentifiable,
    SheetRoute: RouteIdentifiable,
    FullScreenRoute: RouteIdentifiable
>: ObservableObject {

    // MARK: - Stack

    @Published var path: [StackRoute] = []

    // MARK: - Modal

    @Published var sheet: SheetRoute?
    @Published var fullScreen: FullScreenRoute?

    // MARK: - Stack API

    func push(_ route: StackRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func setPath(_ newPath: [StackRoute]) {
        path = newPath
    }

    // MARK: - Sheet API

    func presentSheet(_ route: SheetRoute) {
        sheet = route
    }

    func dismissSheet() {
        sheet = nil
    }

    // MARK: - FullScreen API

    func presentFullScreen(_ route: FullScreenRoute) {
        fullScreen = route
    }

    func dismissFullScreen() {
        fullScreen = nil
    }

    // MARK: - Reset

    func resetAll() {
        path.removeAll()
        sheet = nil
        fullScreen = nil
    }
}
