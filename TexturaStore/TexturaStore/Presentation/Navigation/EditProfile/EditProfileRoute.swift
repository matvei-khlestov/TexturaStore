//
//  EditProfileRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import Foundation

@MainActor
enum EditProfileRoute: @MainActor StackRoutable {
    case root
    case editName
    case editEmail
}
