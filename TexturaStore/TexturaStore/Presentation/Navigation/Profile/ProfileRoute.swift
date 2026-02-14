//
//  ProfileRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 09.02.2026.
//

@MainActor
enum ProfileRoute: @MainActor RouteIdentifiable {
    case privacyPolicy
    case contactUs
    case about
    case settings
    case editProfile
    
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
        case .editProfile:
            return "profile.editProfile"
        }
    }
}
