//
//  Container+LanguageProvider.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import FactoryKit

extension Container {
    
    // MARK: - Localization / Language
    
    /// Провайдер текущего языка приложения.
    ///
    /// Используется:
    /// - в координаторах (для формирования navigationTitle);
    /// - в локализаторах (`DefaultCatalogLocalizer`);
    /// - во View / ViewModel при необходимости реакции на смену языка.
    ///
    /// Scope:
    /// - `.singleton`, так как язык — глобальное состояние приложения.
    var languageProvider: Factory<any LanguageProviding> {
        Factory(self) { @MainActor in
            LocalizationLanguageProvider()
        }
        .scope(.singleton)
    }
}
