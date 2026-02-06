//
//  SignUpView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import SwiftUI
import Combine

/// Экран регистрации пользователя.
///
/// Отвечает за:
/// - ввод имени, e-mail и пароля (`FormTextField`);
/// - подтверждение согласия с политикой (чекбокс + ссылка);
/// - биндинг с `SignUpViewModelProtocol` для валидаций и сабмита;
/// - управление кнопкой «Зарегистрироваться» и навигацией;
/// - обработку нажатий: открыть политику, перейти к логину, назад.
///
/// Особенности:
/// - Combine-подписки на ошибки и доступность сабмита;
/// - закрытие клавиатуры по тапу и по Return;
/// - доступность: расставлены `accessibilityIdentifier`;
/// - адаптивные отступы и поддержка Dynamic Type;
/// - кастомный чекбокс с обновлением UI;
/// - показ ошибок регистрации через алерт.
struct SignUpView: View {
    
    // MARK: - Callbacks
    
    var onOpenPrivacy: (() -> Void)?
    var onLogin: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: SignUpViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 20
            static let verticalTop: CGFloat = 70
            static let verticalBottom: CGFloat = 24
        }
        
        enum Spacing {
            static let formSpacing: CGFloat = 15
            static let agreeRow: CGFloat = 10
        }
        
        enum Checkbox {
            static let size: CGFloat = 20
            static let cornerRadius: CGFloat = 5
            static let borderWidth: CGFloat = 2
            static let checkmarkPoint: CGFloat = 10
        }
        
        enum Fonts {
            static let agreeError: Font = .system(size: 13, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let privacyTitle = L10n.Auth.Signup.privacyTitle
        static let submitTitle  = L10n.Auth.Signup.submit
        static let noteText     = L10n.Auth.Signup.noteText
        static let noteAction   = L10n.Auth.Signup.noteAction
        
        static let errorTitle = L10n.Common.Error.title
        static let okTitle = L10n.Common.ok
        
        static let signUpSuccessTitle = L10n.Auth.Signup.Success.title
        static let signUpSuccessMessage = L10n.Auth.Signup.Success.message
    }
    
    // MARK: - State
    
    @State private var nameText: String = ""
    @State private var emailText: String = ""
    @State private var passwordText: String = ""
    
    @State private var isAgreed: Bool = false
    
    @State private var nameErrorText: String? = nil
    @State private var emailErrorText: String? = nil
    @State private var passwordErrorText: String? = nil
    @State private var agreementErrorText: String? = nil
    
    @State private var isSubmitEnabled: Bool = false
    
    @State private var errorAlertMessage: String? = nil
    @State private var isErrorAlertPresented: Bool = false
    
    @State private var isSignUpSuccessAlertPresented: Bool = false
    
    @State private var bag = Set<AnyCancellable>()
    
    @FocusState private var focusedField: FocusField?
    
    private enum FocusField {
        case name
        case email
        case password
    }
    
    // MARK: - Init
    
    init(
        viewModel: SignUpViewModelProtocol,
        onOpenPrivacy: (() -> Void)? = nil,
        onLogin: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onOpenPrivacy = onOpenPrivacy
        self.onLogin = onLogin
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
        .alert(Texts.signUpSuccessTitle, isPresented: $isSignUpSuccessAlertPresented) {
            Button(Texts.okTitle) {
                onLogin?()
            }
        } message: {
            Text(Texts.signUpSuccessMessage)
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.formSpacing) {
            
            FormTextField(
                kind: .name,
                text: $nameText,
                error: nameErrorText
            ) { value in
                viewModel.setName(value)
            }
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .email
            }
            .accessibilityIdentifier("signup.name")
            
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
            .accessibilityIdentifier("signup.email")
            
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
            .accessibilityIdentifier("signup.password")
            
            agreeRow
            
            agreementErrorRow
            
            BrandedButton(
                style: .submit,
                title: Texts.submitTitle,
                isEnabled: isSubmitEnabled
            ) {
                submitTapped()
            }
            .accessibilityIdentifier("signup.submit")
            
            LabelLinkRow(
                label: Texts.noteText,
                button: Texts.noteAction,
                alignment: .center
            ) {
                onLogin?()
            }
            .accessibilityIdentifier("signup.login")
        }
        .padding(.top, Metrics.Insets.verticalTop)
        .padding(.horizontal, Metrics.Insets.horizontal)
        .padding(.bottom, Metrics.Insets.verticalBottom)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Agree row
    
    private var agreeRow: some View {
        HStack(alignment: .center, spacing: Metrics.Spacing.agreeRow) {
            checkboxButton
                .accessibilityIdentifier("signup.agree.checkbox")
            
            UnderlinedButton(
                text: Texts.privacyTitle,
                alignment: .leading
            ) {
                onOpenPrivacy?()
            }
            .accessibilityIdentifier("signup.agree.link")
            
            Spacer(minLength: 0)
        }
    }
    
    private var checkboxButton: some View {
        Button {
            toggleAgree()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: Metrics.Checkbox.cornerRadius, style: .continuous)
                    .fill(isAgreed ? Color(.brand) : Color.clear)
                
                RoundedRectangle(cornerRadius: Metrics.Checkbox.cornerRadius, style: .continuous)
                    .stroke(Color(.brand), lineWidth: Metrics.Checkbox.borderWidth)
                
                if isAgreed {
                    Image(systemName: "checkmark")
                        .font(.system(size: Metrics.Checkbox.checkmarkPoint, weight: .medium))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(width: Metrics.Checkbox.size, height: Metrics.Checkbox.size)
        }
        .buttonStyle(.plain)
    }
    
    private var agreementErrorRow: some View {
        Text(agreementErrorText ?? "")
            .font(Metrics.Fonts.agreeError)
            .foregroundStyle(Color.red)
            .lineLimit(nil)
            .opacity(agreementErrorText == nil ? 0 : 1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Bindings
    
    private func bindIfNeeded() {
        guard bag.isEmpty else { return }
        
        viewModel.nameError
            .receive(on: RunLoop.main)
            .sink { value in
                nameErrorText = value
            }
            .store(in: &bag)
        
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
        
        viewModel.agreementError
            .receive(on: RunLoop.main)
            .sink { value in
                agreementErrorText = value
            }
            .store(in: &bag)
        
        viewModel.isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { enabled in
                isSubmitEnabled = enabled
            }
            .store(in: &bag)
        
        viewModel.signUpSuccess
            .receive(on: RunLoop.main)
            .sink { _ in
                isSignUpSuccessAlertPresented = true
            }
            .store(in: &bag)
    }
    
    // MARK: - Actions
    
    private func toggleAgree() {
        isAgreed.toggle()
        viewModel.setAgreement(isAgreed)
    }
    
    private func submitTapped() {
        focusedField = nil
        
        Task {
            do {
                try await viewModel.signUp()
            } catch {
                errorAlertMessage = error.localizedDescription
                isErrorAlertPresented = true
            }
        }
    }
}
