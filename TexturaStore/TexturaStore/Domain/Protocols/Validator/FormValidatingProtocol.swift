//
//  FormValidatingProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import Foundation

protocol FormValidatingProtocol {
    func validate(_ text: String, for field: AuthField) -> ValidationResult
}
