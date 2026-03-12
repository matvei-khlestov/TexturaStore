//
//  CartRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import Foundation

@MainActor
enum CartRoute: @MainActor StackRoutable {
    case root
    case productDetails(ProductDetailsRoute)
    case checkout(CheckoutRoute, snapshotItems: [CartItem])
}
