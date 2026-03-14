//
//  CartCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
protocol CartCoordinating: Coordinator {
    var router: AppRouter<CartRoute, NoRoute, NoRoute> { get }
    
    func makeRoot() -> AnyView
    func buildStack(_ route: CartRoute) -> AnyView
    
    func start()
    func finish()
}
