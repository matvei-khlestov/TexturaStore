//
//  Category.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 18.02.2026.
//

import Foundation

struct Category: Codable, Equatable {
    let id: String
    let nameRu: String
    let nameEn: String
    let imageURL: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}
