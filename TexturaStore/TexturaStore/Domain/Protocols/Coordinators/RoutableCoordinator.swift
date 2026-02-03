//
//  RoutableCoordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

@MainActor
protocol RoutableCoordinator: Coordinator, ObservableObject {
    
    associatedtype StackRoute: RouteIdentifiable
    associatedtype SheetRoute: RouteIdentifiable = NoRoute
    associatedtype FullScreenRoute: RouteIdentifiable = NoRoute
    
    var router: AppRouter<StackRoute, SheetRoute, FullScreenRoute> { get }
    
    func makeRoot() -> AnyView
    func buildStack(_ route: StackRoute) -> AnyView
    func buildSheet(_ route: SheetRoute) -> AnyView
    func buildFullScreen(_ route: FullScreenRoute) -> AnyView
}

@MainActor
extension RoutableCoordinator {
    
    var rootView: AnyView {
        AnyView(
            NavigationHost(
                router: router,
                root: { [self] in
                    self.makeRoot()
                },
                stackDestination: { [self] route in
                    self.buildStack(route)
                },
                sheetDestination: { [self] route in
                    self.buildSheet(route)
                },
                fullScreenDestination: { [self] route in
                    self.buildFullScreen(route)
                }
            )
        )
    }
}

@MainActor
extension RoutableCoordinator where SheetRoute == NoRoute {
    func buildSheet(_ route: NoRoute) -> AnyView { AnyView(EmptyView()) }
}

@MainActor
extension RoutableCoordinator where FullScreenRoute == NoRoute {
    func buildFullScreen(_ route: NoRoute) -> AnyView { AnyView(EmptyView()) }
}
