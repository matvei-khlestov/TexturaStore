//
//  DefaultCatalogLocalizer.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import Foundation

struct DefaultCatalogLocalizer: CatalogLocalizing {
    
    private let languageProvider: LanguageProviding
    
    init(languageProvider: LanguageProviding) {
        self.languageProvider = languageProvider
    }
    
    func categoryTitle(_ category: Category) -> String {
        switch languageProvider.currentLanguage {
        case .ru:
            return category.nameRu
        case .en:
            return category.nameEn
        }
    }
    
    func productTitle(_ product: Product) -> String {
        switch languageProvider.currentLanguage {
        case .ru:
            return product.nameRu
        case .en:
            return product.nameEn
        }
    }
    
    func colorTitle(_ color: ProductColor) -> String {
        switch languageProvider.currentLanguage {
        case .ru:
            return color.nameRu
        case .en:
            return color.nameEn
        }
    }
}
