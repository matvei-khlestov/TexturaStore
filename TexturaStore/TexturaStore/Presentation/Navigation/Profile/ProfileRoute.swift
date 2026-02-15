//
//  ProfileRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 09.02.2026.
//

import Foundation

@MainActor
enum ProfileRoute: @MainActor StackRoutable {
    case root
    case settings
    case about
    case contactUs
    case privacyPolicy
    case edit(EditProfileRoute)
}
