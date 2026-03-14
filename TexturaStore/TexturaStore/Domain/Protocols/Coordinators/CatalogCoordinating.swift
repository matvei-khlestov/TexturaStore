//
//  CatalogCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
protocol CatalogCoordinating: Coordinator {
    var router: AppRouter<CatalogRoute, NoRoute, NoRoute> { get }
    
    func makeRoot() -> AnyView
    func buildStack(_ route: CatalogRoute) -> AnyView
    
    func start()
    func finish()
}
