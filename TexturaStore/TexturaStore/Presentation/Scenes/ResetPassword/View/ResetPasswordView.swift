//
//  ResetPasswordView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI
import Combine

/// Экран `ResetPasswordView` для восстановления пароля.
///
/// Отвечает за:
/// - ввод e-mail и биндинг с `ResetPasswordViewModelProtocol`;
/// - отображение ошибок валидации и состояния кнопки отправки;
/// - запуск `resetPassword()` и показ результата (алерт);
/// - маршрутизацию через колбэки `onBack` и `onDone`;
/// - скрытие клавиатуры по тапу.
struct ResetPasswordView: View {

    // MARK: - Callbacks

    let onBack: () -> Void
    let onDone: () -> Void

    // MARK: - Dependencies

    private let viewModel: ResetPasswordViewModelProtocol

    // MARK: - State

    @State private var emailText: String = ""
    @State private var emailErrorText: String?
    @State private var isSubmitEnabled: Bool = false

    @State private var isShowingDoneAlert: Bool = false
    @State private var isShowingErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    @State private var bag = Set<AnyCancellable>()

    // MARK: - Metrics

    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 20
            static let verticalTop: CGFloat = 70
            static let verticalBottom: CGFloat = 24
        }

        enum Spacing {
            static let form: CGFloat = 18
        }

        enum Fonts {
            static let title = Font.system(size: 28, weight: .bold)
            static let subtitle = Font.system(size: 15, weight: .regular)
        }
    }

    // MARK: - Init

    init(
        viewModel: ResetPasswordViewModelProtocol,
        onBack: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onDone = onDone
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.form) {
            Text(L10n.Auth.Reset.title)
                .font(Metrics.Fonts.title)
                .foregroundStyle(Color.primary)

            Text(L10n.Auth.Reset.subtitle)
                .font(Metrics.Fonts.subtitle)
                .foregroundStyle(Color(.secondaryLabel))

            FormTextField(
                kind: .email,
                text: $emailText,
                error: emailErrorText,
                onTextChanged: { [viewModel] text in
                    viewModel.setEmail(text)
                }
            )
            .submitLabel(.done)
            .onSubmit {
                submitFromKeyboard()
            }

            BrandedButton(
                style: .submit,
                title: L10n.Auth.Reset.submit,
                isEnabled: isSubmitEnabled
            ) {
                submitTapped()
            }

            LabelLinkRow(
                label: L10n.Auth.Reset.backRowLabel,
                button: L10n.Auth.Reset.backRowAction,
                alignment: .center
            ) {
                onBack()
            }

            Spacer(minLength: 0)
        }
        .padding(.top, Metrics.Insets.verticalTop)
        .padding(.horizontal, Metrics.Insets.horizontal)
        .padding(.bottom, Metrics.Insets.verticalBottom)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .brandBackButton(onBack: onBack)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            bind()
        }
        .alert(L10n.Auth.Reset.Alert.Done.title, isPresented: $isShowingDoneAlert) {
            Button(L10n.Common.ok) {
                onDone()
            }
        } message: {
            Text(L10n.Auth.Reset.Alert.Done.message)
        }
        .alert(L10n.Common.Error.title, isPresented: $isShowingErrorAlert) {
            Button(L10n.Common.ok) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Bind

    private func bind() {
        bag.removeAll()

        viewModel.emailError
            .receive(on: RunLoop.main)
            .sink { value in
                emailErrorText = value
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
        hideKeyboard()

        Task {
            do {
                try await viewModel.resetPassword()
                isShowingDoneAlert = true
            } catch {
                errorMessage = error.localizedDescription
                isShowingErrorAlert = true
            }
        }
    }

    private func submitFromKeyboard() {
        hideKeyboard()
        if isSubmitEnabled {
            submitTapped()
        }
    }
}

// MARK: - Keyboard

private extension ResetPasswordView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
