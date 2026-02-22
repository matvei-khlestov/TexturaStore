//
//  CartScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

@MainActor
protocol CartScreenBuilding {
    func makeCartView(
        viewModel: CartViewModelProtocol,
        onCheckout: (() -> Void)?,
        onSelectProductId: ((String) -> Void)?
    ) -> AnyView
}
