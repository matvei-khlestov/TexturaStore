//
//  SettingsStorage.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation

final class SettingsStorage: SettingsStorageProtocol {
    
    // MARK: - Keys
    
    private enum Keys {
        static let language: String = "settings.language"
        static let theme: String = "settings.theme"
    }
    
    // MARK: - Dependencies
    
    private let prefs: PreferencesStore
    
    // MARK: - Init
    
    init(prefs: PreferencesStore = DefaultsStore()) {
        self.prefs = prefs
    }
    
    // MARK: - Language
    
    func loadLanguage() -> AppLanguage {
        guard let raw = prefs.string(forKey: Keys.language),
              let value = AppLanguage(rawValue: raw) else {
            return .ru
        }
        return value
    }
    
    func saveLanguage(_ language: AppLanguage) {
        prefs.set(language.rawValue, forKey: Keys.language)
    }
    
    // MARK: - Theme
    
    func loadTheme() -> AppTheme {
        guard let raw = prefs.string(forKey: Keys.theme),
              let value = AppTheme(rawValue: raw) else {
            return .system
        }
        return value
    }
    
    func saveTheme(_ theme: AppTheme) {
        prefs.set(theme.rawValue, forKey: Keys.theme)
    }
    
    // MARK: - Reset
    
    func reset() {
        prefs.remove(Keys.language)
        prefs.remove(Keys.theme)
    }
}
