//
//  ProfileEditRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import Foundation

@MainActor
enum ProfileEditRoute: @MainActor RouteIdentifiable {
    case root
    
    var id: String {
        switch self {
        case .root:
            return "profileEdit.root"
        }
    }
}
