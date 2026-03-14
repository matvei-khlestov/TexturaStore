//
//  FavoriteItem.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation

struct FavoriteItem: Equatable, Hashable {
    let userId: String
    let productId: String
    var brandName: String
    var title: String
    var price: Double
    var imageURL: String?
    var updatedAt: Date
}
