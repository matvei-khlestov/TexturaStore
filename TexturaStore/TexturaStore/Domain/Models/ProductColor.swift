//
//  ProductColor.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 18.02.2026.
//

import Foundation

struct ProductColor: Equatable, Identifiable {
    let id: String
    let nameRu: String
    let nameEn: String
    let hex: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}
