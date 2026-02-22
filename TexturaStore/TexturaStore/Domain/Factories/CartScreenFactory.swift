//
//  CartScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

@MainActor
final class CartScreenFactory: CartScreenBuilding {
    
    func makeCartView(
        viewModel: CartViewModelProtocol,
        onCheckout: (() -> Void)?,
        onSelectProductId: ((String) -> Void)?
    ) -> AnyView {
        AnyView(
            CartView(
                viewModel: viewModel,
                onCheckout: onCheckout,
                onSelectProductId: onSelectProductId
            )
        )
    }
}
