//
//  Product.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 18.02.2026.
//

import Foundation

struct Product: Codable, Equatable {
    let id: String
    let categoryId: String
    let brandId: String
    let colorId: String
    let price: Double
    let imageURL: String
    let nameRu: String
    let nameEn: String
    let descriptionRu: String
    let descriptionEn: String
    let nameLowerRu: String
    let nameLowerEn: String
    let ratingAvg: Double
    let ratingCount: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}
