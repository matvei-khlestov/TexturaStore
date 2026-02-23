//
//  ProductDetailsNavigating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

@MainActor
protocol ProductDetailsNavigating {
    func makeRoot(
        productId: String,
        onBack: @escaping () -> Void
    ) -> AnyView
    
    func makeDestination(
        route: ProductDetailsRoute,
        onBack: @escaping () -> Void
    ) -> AnyView
}
