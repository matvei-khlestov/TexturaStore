//
//  FavoritesCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
protocol FavoritesCoordinating: Coordinator {
    var router: AppRouter<FavoritesRoute, NoRoute, NoRoute> { get }
    
    func makeRoot() -> AnyView
    func buildStack(_ route: FavoritesRoute) -> AnyView
    
    func start()
    func finish()
}
