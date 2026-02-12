//
//  SettingsService.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SettingsService: SettingsServiceProtocol, ObservableObject {
    
    // MARK: - Published
    
    @Published private(set) var language: AppLanguage
    @Published private(set) var theme: AppTheme
    
    // MARK: - Dependencies
    
    private let storage: SettingsStorageProtocol
    private let localization: LocalizationManager
    
    // MARK: - Init
    
    init(
        storage: SettingsStorageProtocol,
        localization: LocalizationManager? = nil
    ) {
        self.storage = storage
        self.localization = localization ?? .shared
        
        self.language = storage.loadLanguage()
        self.theme = storage.loadTheme()
        
        // Apply on app start
        self.localization.apply(language: self.language)
    }
    
    // MARK: - Outputs
    
    var languagePublisher: AnyPublisher<AppLanguage, Never> {
        $language.eraseToAnyPublisher()
    }
    
    var themePublisher: AnyPublisher<AppTheme, Never> {
        $theme.eraseToAnyPublisher()
    }
    
    // MARK: - Theme
    
    var preferredColorScheme: ColorScheme? {
        theme.preferredColorScheme
    }
    
    // MARK: - Actions
    
    func setLanguage(_ language: AppLanguage) {
        guard self.language != language else { return }
        self.language = language
        storage.saveLanguage(language)
        localization.apply(language: language)
    }
    
    func setTheme(_ theme: AppTheme) {
        guard self.theme != theme else { return }
        self.theme = theme
        storage.saveTheme(theme)
    }
}
