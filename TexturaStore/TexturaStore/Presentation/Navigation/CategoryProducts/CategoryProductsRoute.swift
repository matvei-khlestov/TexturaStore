//
//  CategoryProductsRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import Foundation

@MainActor
enum CategoryProductsRoute: @MainActor StackRoutable {
    case root(categoryId: String, title: String)
}
