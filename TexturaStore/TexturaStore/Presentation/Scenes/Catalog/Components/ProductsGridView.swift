//
//  ProductsGridView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

struct ProductsGridView: View {
    
    let products: [Product]
    let minColumnWidth: CGFloat
    let rowSpacing: CGFloat
    
    let isInCart: (String) -> Bool
    let isFavorite: (String) -> Bool
    let formattedPrice: (Double) -> String
    let productTitle: (Product) -> String
    
    let onSelect: (Product) -> Void
    let onToggleCart: (Product, Bool) -> Void
    let onToggleFavorite: (Product) -> Void
    
    var body: some View {
        let columns = [GridItem(.adaptive(minimum: minColumnWidth), spacing: rowSpacing)]
        
        LazyVGrid(columns: columns, spacing: rowSpacing) {
            ForEach(products, id: \.id) { product in
                ProductCardView(
                    product: product,
                    title: productTitle(product),
                    isFavorite: isFavorite(product.id),
                    isInCart: isInCart(product.id),
                    priceText: formattedPrice(product.price),
                    onToggleCart: { toInCart in
                        onToggleCart(product, toInCart)
                    },
                    onToggleFavorite: {
                        onToggleFavorite(product)
                    }
                )
                .onTapGesture {
                    onSelect(product)
                }
            }
        }
    }
}
