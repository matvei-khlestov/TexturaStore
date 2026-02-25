//
//  FilterState.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation

struct FilterState: Equatable {
    var selectedCategoryIds: Set<String> = []
    var selectedBrandIds: Set<String> = []
    var selectedColorIds: Set<String> = []
    var minPrice: Decimal?
    var maxPrice: Decimal?

    var isEmpty: Bool {
        selectedCategoryIds.isEmpty
        && selectedBrandIds.isEmpty
        && selectedColorIds.isEmpty
        && minPrice == nil
        && maxPrice == nil
    }
}

extension FilterState {
    var hasPrice: Bool { minPrice != nil || maxPrice != nil }
    
    var isPriceValid: Bool {
        guard let min = minPrice, let max = maxPrice else { return true }
        return min <= max
    }
}
