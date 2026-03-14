//
//  Brand.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 18.02.2026.
//

import Foundation

struct Brand: Codable, Equatable {
    let id: String
    let name: String
    let imageURL: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}
