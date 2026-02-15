//
//  ProfileCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

@MainActor
protocol ProfileCoordinating: Coordinator {
    var router: AppRouter<ProfileRoute, NoRoute, NoRoute> { get }

    var onOrdersTap:     (() -> Void)? { get set }
    var onLogout:        (() -> Void)? { get set }
    var onDeleteAccount: (() -> Void)? { get set }

    func makeRoot() -> AnyView
    func buildStack(_ route: ProfileRoute) -> AnyView

    func start()
    func finish()
}
