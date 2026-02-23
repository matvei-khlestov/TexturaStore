//
//  ProductDetailsRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import Foundation

@MainActor
enum ProductDetailsRoute: @MainActor StackRoutable {
    case root(productId: String)
}
