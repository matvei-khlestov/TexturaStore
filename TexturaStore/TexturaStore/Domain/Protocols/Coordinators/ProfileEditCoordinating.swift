//
//  ProfileEditCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import SwiftUI

@MainActor
protocol ProfileEditCoordinating: Coordinator {
    var router: AppRouter<ProfileEditRoute, NoRoute, NoRoute> { get }
    
    var onEditName:  (() -> Void)? { get set }
    var onEditEmail: (() -> Void)? { get set }
    var onEditPhone: (() -> Void)? { get set }
    var onFinish:    (() -> Void)? { get set }
    
    func makeRoot() -> AnyView
    func buildStack(_ route: ProfileEditRoute) -> AnyView
    
    func start()
    func finish()
}
