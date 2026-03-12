//
//  OrderItem.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation

struct OrderItem: Equatable, Identifiable {
    var id: String { product.id }
    let product: Product
    let quantity: Int
    
    var lineTotal: Double {
        product.price * Double(quantity)
    }
}
