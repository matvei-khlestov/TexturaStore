//
//  SettingsViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import Combine

@MainActor
protocol SettingsViewModelProtocol: AnyObject {
    
    // MARK: - Current Values
    
    var currentLanguage: AppLanguage { get }
    var currentTheme: AppTheme { get }
    
    // MARK: - Outputs
    
    var language: AnyPublisher<AppLanguage, Never> { get }
    var theme: AnyPublisher<AppTheme, Never> { get }
    
    // MARK: - Inputs
    
    func setLanguage(_ value: AppLanguage)
    func setTheme(_ value: AppTheme)
}

