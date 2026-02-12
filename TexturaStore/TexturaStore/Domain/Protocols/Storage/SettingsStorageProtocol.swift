//
//  SettingsStorageProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation

protocol SettingsStorageProtocol {
    func loadLanguage() -> AppLanguage
    func saveLanguage(_ language: AppLanguage)

    func loadTheme() -> AppTheme
    func saveTheme(_ theme: AppTheme)
}
