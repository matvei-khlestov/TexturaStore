//
//  ValidationResult.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import Foundation

struct ValidationResult {
    let isValid: Bool
    let messages: [String]
    var message: String? { messages.first }
}
