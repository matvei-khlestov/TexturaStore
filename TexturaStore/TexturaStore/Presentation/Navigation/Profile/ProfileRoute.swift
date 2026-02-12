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

    var id: String {
        switch self {
        case .privacyPolicy:
            return "profile.privacyPolicy"
        }
    }
}
