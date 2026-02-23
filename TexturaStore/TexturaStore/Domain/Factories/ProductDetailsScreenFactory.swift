//
//  ProductDetailsScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

@MainActor
final class ProductDetailsScreenFactory: ProductDetailsScreenBuilding {
    
    func makeProductDetailsView(
        viewModel: ProductDetailsViewModelProtocol,
        onBack: (() -> Void)?
    ) -> AnyView {
        AnyView(
            ProductDetailsView(
                viewModel: viewModel,
                onBack: onBack
            )
        )
    }
}
