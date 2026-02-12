//
//  ProfileRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 09.02.2026.
//

import Foundation

@MainActor
enum ProfileRoute: @MainActor RouteIdentifiable {
    case privacyPolicy
    case contactUs
    case about
    case settings
    
    var id: String {
        switch self {
        case .privacyPolicy:
            return "profile.privacyPolicy"
        case .contactUs:
            return "profile.contactUs"
        case .about:
            return "profile.about"
        case .settings:
            return "profile.settings"
        }
    }
}
