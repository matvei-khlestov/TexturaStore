//
//  ProductReview.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.03.2026.
//

import Foundation

struct ProductReview: Codable, Equatable {
    let id: String
    let productId: String
    let userId: String
    let rating: Int
    let comment: String?
    let userName: String
    let userAvatarURL: String?
    let createdAt: Date
    let updatedAt: Date
}
