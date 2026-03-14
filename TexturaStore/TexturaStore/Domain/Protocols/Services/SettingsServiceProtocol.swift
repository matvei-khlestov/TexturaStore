//
//  SettingsServiceProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
protocol SettingsServiceProtocol: AnyObject {
    
    // MARK: - Current Values
    
    var language: AppLanguage { get }
    var theme: AppTheme { get }
    
    // MARK: - Outputs
    
    var languagePublisher: AnyPublisher<AppLanguage, Never> { get }
    var themePublisher: AnyPublisher<AppTheme, Never> { get }
    
    // MARK: - Theme
    
    var preferredColorScheme: ColorScheme? { get }
    
    // MARK: - Actions
    
    func setLanguage(_ language: AppLanguage)
    func setTheme(_ theme: AppTheme)
}
