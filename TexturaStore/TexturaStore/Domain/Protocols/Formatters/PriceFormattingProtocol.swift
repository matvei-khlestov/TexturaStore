//
//  PriceFormattingProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation

protocol PriceFormattingProtocol {
    /// Форматирует число в строку вида `"1 290 ₽"`
    func format(price: Double) -> String
}
