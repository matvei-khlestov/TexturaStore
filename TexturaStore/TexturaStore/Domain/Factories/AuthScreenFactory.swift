//
//  AuthScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

@MainActor
final class AuthScreenFactory: AuthScreenBuilding {
    
    private let signInViewModel: SignInViewModelProtocol
    private let signUpViewModel: SignUpViewModelProtocol
    
    init(
        signInViewModel: SignInViewModelProtocol,
        signUpViewModel: SignUpViewModelProtocol
    ) {
        self.signInViewModel = signInViewModel
        self.signUpViewModel = signUpViewModel
    }
    
    func makeAuthRootView(
        start: AuthRootView.Mode,
        onOpenPrivacy: @escaping () -> Void,
        onForgotPassword: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            AuthRootView(
                signInViewModel: signInViewModel,
                signUpViewModel: signUpViewModel,
                start: start,
                onOpenPrivacy: onOpenPrivacy,
                onForgotPassword: onForgotPassword
            )
        )
    }
}
