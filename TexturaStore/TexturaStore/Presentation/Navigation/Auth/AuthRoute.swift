//
//  AuthRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import Foundation

enum AuthRoute: @MainActor RouteIdentifiable {
    case privacyPolicy
    case resetPassword
    
    var id: String {
        switch self {
        case .privacyPolicy:
            return "auth.privacyPolicy"
        case .resetPassword:
            return "auth.resetPassword"
        }
    }
}
