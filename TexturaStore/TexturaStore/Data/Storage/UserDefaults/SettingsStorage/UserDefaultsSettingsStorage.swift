//
//  UserDefaultsSettingsStorage.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation

final class UserDefaultsSettingsStorage: SettingsStorageProtocol {
    
    // MARK: - Keys
    
    private enum Keys {
        static let language: String = "settings.language"
        static let theme: String = "settings.theme"
    }
    
    // MARK: - Dependencies
    
    private let userDefaults: UserDefaults
    
    // MARK: - Init
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Language
    
    func loadLanguage() -> AppLanguage {
        guard let raw = userDefaults.string(forKey: Keys.language),
              let value = AppLanguage(rawValue: raw) else {
            return .ru
        }
        return value
    }
    
    func saveLanguage(_ language: AppLanguage) {
        userDefaults.set(language.rawValue, forKey: Keys.language)
    }
    
    // MARK: - Theme
    
    func loadTheme() -> AppTheme {
        guard let raw = userDefaults.string(forKey: Keys.theme),
              let value = AppTheme(rawValue: raw) else {
            return .system
        }
        return value
    }
    
    func saveTheme(_ theme: AppTheme) {
        userDefaults.set(theme.rawValue, forKey: Keys.theme)
    }
}
