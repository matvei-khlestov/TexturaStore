//
//  CatalogLocalizing.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

protocol CatalogLocalizing {
    func categoryTitle(_ category: Category) -> String
    func productTitle(_ product: Product) -> String
    func colorTitle(_ color: ProductColor) -> String
}
