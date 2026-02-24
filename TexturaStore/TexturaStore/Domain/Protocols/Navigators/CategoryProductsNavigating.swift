//
//  CategoryProductsNavigating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

@MainActor
protocol CategoryProductsNavigating {
    func makeRoot(
        categoryId: String,
        title: String,
        onBack: @escaping () -> Void,
        onSelectProduct: @escaping (Product) -> Void
    ) -> AnyView
}
