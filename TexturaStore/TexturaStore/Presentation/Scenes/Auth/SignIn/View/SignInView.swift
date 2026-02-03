//
//  SignInView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import SwiftUI
import Combine

/// Экран авторизации пользователя.
///
/// Отвечает за:
/// - отображение формы входа с полями e-mail и пароля (`FormTextField`);
/// - биндинг с `SignInViewModelProtocol` для валидаций и состояния сабмита;
/// - управление кнопкой «Войти»;
/// - переходы на экраны восстановления пароля и регистрации.
///
/// Особенности:
/// - Combine-подписки на ошибки и доступность сабмита;
/// - закрытие клавиатуры по тапу и по Return;
/// - перевод фокуса: e-mail -> password;
/// - показ ошибок входа через алерт.
struct SignInView: View {
    
    // MARK: - Callbacks
    
    var onOpenSignUp: (() -> Void)?
    var onForgotPassword: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: SignInViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 20
            static let verticalTop: CGFloat = 0
            static let verticalBottom: CGFloat = 24
        }
        
        enum Spacing {
            static let formSpacing: CGFloat = 15
        }
        
        enum Fonts {
            static let forgot: Font = .system(size: 15, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let forgotPasswordTitle = L10n.Auth.Signin.forgotPassword
        static let submitTitle = L10n.Auth.Signin.submit
        static let noteText = L10n.Auth.Signin.noteText
        static let noteAction = L10n.Auth.Signin.noteAction
        
        static let errorTitle = L10n.Common.Error.title
        static let okTitle = L10n.Common.ok
    }
    
    // MARK: - State
    
    @State private var emailText: String = ""
    @State private var passwordText: String = ""
    
    @State private var emailErrorText: String? = nil
    @State private var passwordErrorText: String? = nil
    @State private var isSubmitEnabled: Bool = false
    
    @State private var errorAlertMessage: String? = nil
    @State private var isErrorAlertPresented: Bool = false
    
    @State private var bag = Set<AnyCancellable>()
    
    @FocusState private var focusedField: FocusField?
    
    private enum FocusField {
        case email
        case password
    }
    
    // MARK: - Init
    
    init(
        viewModel: SignInViewModelProtocol,
        onOpenSignUp: (() -> Void)? = nil,
        onForgotPassword: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onOpenSignUp = onOpenSignUp
        self.onForgotPassword = onForgotPassword
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(.systemBackground))
        .onAppear {
            bindIfNeeded()
        }
        .onTapGesture {
            focusedField = nil
        }
        .alert(Texts.errorTitle, isPresented: $isErrorAlertPresented) {
            Button(Texts.okTitle, role: .cancel) {}
        } message: {
            Text(errorAlertMessage ?? "")
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.formSpacing) {
            FormTextField(
                kind: .email,
                text: $emailText,
                error: emailErrorText
            ) { value in
                viewModel.setEmail(value)
            }
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }
            
            FormTextField(
                kind: .password,
                text: $passwordText,
                error: passwordErrorText
            ) { value in
                viewModel.setPassword(value)
            }
            .focused($focusedField, equals: .password)
            .submitLabel(.done)
            .onSubmit {
                focusedField = nil
            }
            
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                
                UnderlinedButton(
                    text: Texts.forgotPasswordTitle,
                    alignment: .trailing
                ) {
                    onForgotPassword?()
                }
                .font(Metrics.Fonts.forgot)
            }
            
            BrandedButton(
                style: .submit,
                title: Texts.submitTitle,
                isEnabled: isSubmitEnabled
            ) {
                submitTapped()
            }
            
            LabelLinkRow(
                label: Texts.noteText,
                button: Texts.noteAction,
                alignment: .center
            ) {
                onOpenSignUp?()
            }
        }
        .padding(.top, Metrics.Insets.verticalTop)
        .padding(.horizontal, Metrics.Insets.horizontal)
        .padding(.bottom, Metrics.Insets.verticalBottom)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Bindings
    
    private func bindIfNeeded() {
        guard bag.isEmpty else { return }
        
        viewModel.emailError
            .receive(on: RunLoop.main)
            .sink { value in
                emailErrorText = value
            }
            .store(in: &bag)
        
        viewModel.passwordError
            .receive(on: RunLoop.main)
            .sink { value in
                passwordErrorText = value
            }
            .store(in: &bag)
        
        viewModel.isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { enabled in
                isSubmitEnabled = enabled
            }
            .store(in: &bag)
    }
    
    // MARK: - Actions
    
    private func submitTapped() {
        focusedField = nil
        
        Task {
            do {
                try await viewModel.signIn()
            } catch {
                errorAlertMessage = error.localizedDescription
                isErrorAlertPresented = true
            }
        }
    }
}

