//
//  AppLanguage.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    
    case ru
    case en
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .ru:
            return L10n.Settings.Language.ru
        case .en:
            return L10n.Settings.Language.en
        }
    }
}
