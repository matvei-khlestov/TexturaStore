//
//  LocalizationLanguageProvider.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import Foundation
import Combine

final class LocalizationLanguageProvider: LanguageProviding {
    
    private let manager: LocalizationManager
    
    init(manager: LocalizationManager = .shared) {
        self.manager = manager
    }
    
    var languagePublisher: AnyPublisher<AppLanguage, Never> {
        manager.$language.eraseToAnyPublisher()
    }
    
    var currentLanguage: AppLanguage {
        manager.language
    }
}
