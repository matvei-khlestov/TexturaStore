//
//  ProductDetailsScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

@MainActor
protocol ProductDetailsScreenBuilding {
    func makeProductDetailsView(
        viewModel: ProductDetailsViewModelProtocol,
        onBack: (() -> Void)?
    ) -> AnyView
}
