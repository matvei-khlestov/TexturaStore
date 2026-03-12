//
//  DefaultOrdersLocalizer.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import Foundation

struct DefaultOrdersLocalizer: OrdersLocalizing {
    
    // MARK: - Deps
    
    private let languageProvider: any LanguageProviding
    
    // MARK: - Init
    
    init(languageProvider: any LanguageProviding) {
        self.languageProvider = languageProvider
    }
    
    // MARK: - OrdersLocalizing
    
    func productTitle(_ product: Product) -> String {
        switch languageProvider.currentLanguage {
        case .ru:
            return product.nameRu
        case .en:
            return product.nameEn
        }
    }
}
