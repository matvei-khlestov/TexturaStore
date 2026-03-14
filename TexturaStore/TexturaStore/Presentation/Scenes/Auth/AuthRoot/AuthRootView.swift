//
//  AuthRootView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

/// Контейнер-вью `AuthRootView` для экранов аутентификации.
///
/// Отвечает за:
/// - переключение режимов между `SignInView` и `SignUpView`;
/// - управление заголовком навигации в зависимости от режима;
/// - маршрутизацию событий наружу через колбэки:
///   `onOpenPrivacy`, `onForgotPassword`;
/// - анимированную смену контента (кросс-фейд).
///
/// Особенности:
/// - инкапсулирует переключение режимов без пересозданий ViewModel;
/// - предотвращает лишние переключения при повторном выборе того же режима;
/// - бизнес-логика регистрации/входа находится во вложенных View и их ViewModel.
struct AuthRootView: View {
    
    // MARK: - Mode
    
    enum Mode: Equatable {
        case signIn
        case signUp
    }
    
    // MARK: - Callbacks
    
    var onOpenPrivacy: (() -> Void)?
    var onForgotPassword: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Durations {
            static let crossfade: Double = 0.25
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let signInTitle = L10n.Auth.Root.Signin.title
        static let signUpTitle = L10n.Auth.Root.Signup.title
    }
    
    // MARK: - Dependencies
    
    private let signInViewModel: SignInViewModelProtocol
    private let signUpViewModel: SignUpViewModelProtocol
    
    // MARK: - State
    
    @State private var mode: Mode
    
    // MARK: - Init
    
    init(
        signInViewModel: SignInViewModelProtocol,
        signUpViewModel: SignUpViewModelProtocol,
        start mode: Mode = .signIn,
        onOpenPrivacy: (() -> Void)? = nil,
        onForgotPassword: (() -> Void)? = nil
    ) {
        self.signInViewModel = signInViewModel
        self.signUpViewModel = signUpViewModel
        self._mode = State(initialValue: mode)
        self.onOpenPrivacy = onOpenPrivacy
        self.onForgotPassword = onForgotPassword
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .background(Color(.systemBackground))
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        ZStack {
            switch mode {
            case .signIn:
                signInView
                    .transition(.opacity)
                
            case .signUp:
                signUpView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: Metrics.Durations.crossfade), value: mode)
    }
    
    // MARK: - Child views
    
    private var signInView: some View {
        SignInView(
            viewModel: signInViewModel,
            onOpenSignUp: { setMode(.signUp, animated: true) },
            onForgotPassword: { onForgotPassword?() }
        )
    }
    
    private var signUpView: some View {
        SignUpView(
            viewModel: signUpViewModel,
            onOpenPrivacy: { onOpenPrivacy?() },
            onLogin: { setMode(.signIn, animated: true) }
        )
    }
    
    // MARK: - Mode
    
    private func setMode(_ newMode: Mode, animated: Bool) {
        guard mode != newMode else { return }
        
        if animated {
            mode = newMode
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { mode = newMode }
        }
    }
    
    private var navigationTitle: String {
        switch mode {
        case .signIn:
            return Texts.signInTitle
        case .signUp:
            return Texts.signUpTitle
        }
    }
}
