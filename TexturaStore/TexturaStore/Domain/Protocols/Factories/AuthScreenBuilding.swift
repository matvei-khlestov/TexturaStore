//
//  AuthScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

@MainActor
protocol AuthScreenBuilding {
    
    func makeAuthRootView(
        start: AuthRootView.Mode,
        onOpenPrivacy: @escaping () -> Void,
        onForgotPassword: @escaping () -> Void
    ) -> AnyView
    
    func makeResetPasswordView(
        viewModel: any ResetPasswordViewModelProtocol,
        onBack: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) -> AnyView
}
