//
//  AppTheme.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    
    case light
    case dark
    case system
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .light:
            return L10n.Settings.Theme.light
        case .dark:
            return L10n.Settings.Theme.dark
        case .system:
            return L10n.Settings.Theme.system
        }
    }
    
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
