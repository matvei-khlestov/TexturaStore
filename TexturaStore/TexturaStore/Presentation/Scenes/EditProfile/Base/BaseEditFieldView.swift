//
//  BaseEditFieldView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import SwiftUI
import Combine

/// SwiftUI-экран редактирования одного поля профиля.
///
/// Поведение соответствует `BaseEditFieldViewController`:
/// - ввод/валидация через ViewModel (`BaseEditFieldViewModelProtocol`);
/// - показ ошибок;
/// - состояние кнопки submit от `isSubmitEnabled`;
/// - `onBack` / `onFinish` колбэки;
/// - телефон: UI хранит display, во ViewModel уходит e164 через `onTextChanged`.
struct BaseEditFieldView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: BaseEditFieldViewModelProtocol
    
    // MARK: - Config
    
    private let fieldKind: FormTextFieldKind
    private let navTitle: String
    private let phoneFormatter: PhoneFormattingProtocol?
    
    // MARK: - State
    
    @State private var text: String = ""
    @State private var errorText: String? = nil
    @State private var isSubmitEnabled: Bool = false
    
    @State private var isPresentingError: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var isPresentingSuccess: Bool = false
    @State private var successTitle: String = ""
    @State private var successMessage: String = ""
    
    // MARK: - Constants
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 60
            static let verticalBottom: CGFloat = 24
        }
        
        enum Spacing {
            static let formVertical: CGFloat = 16
        }
    }
    
    private enum Texts {
        static let submitButtonTitle = "Изменить"
        
        static let emailSuccessTitle = "Проверьте почту"
        static let emailSuccessMessage = "Мы отправили письмо для подтверждения смены e-mail на старую и новую почту."
        
        static let nameSuccessTitle = "Готово"
        static let nameSuccessMessage = "Имя успешно изменено."
        
        static let phoneSuccessTitle = "Готово"
        static let phoneSuccessMessage = "Номер телефона успешно изменён."
    }
    
    // MARK: - Init
    
    init(
        viewModel: BaseEditFieldViewModelProtocol,
        fieldKind: FormTextFieldKind,
        navTitle: String,
        phoneFormatter: PhoneFormattingProtocol? = nil,
        onBack: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.fieldKind = fieldKind
        self.navTitle = navTitle
        self.phoneFormatter = phoneFormatter
        self.onBack = onBack
        self.onFinish = onFinish
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Metrics.Spacing.formVertical) {
            FormTextField(
                kind: fieldKind,
                text: $text,
                error: errorText,
                phoneFormatter: phoneFormatter,
                onTextChanged: { newValue in
                    viewModel.setValue(newValue)
                }
            )
            
            BrandedButton(
                style: .submit,
                title: Texts.submitButtonTitle,
                isEnabled: isSubmitEnabled,
                action: submitTapped
            )
        }
        .padding(.horizontal, Metrics.Insets.horizontal)
        .padding(.top, Metrics.Insets.verticalTop)
        .padding(.bottom, Metrics.Insets.verticalBottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton(onBack: { onBack?() })
        .onAppear {
            applyInitialValueFromViewModel()
        }
        .onReceive(viewModel.error.receive(on: RunLoop.main)) { value in
            errorText = value
        }
        .onReceive(viewModel.isSubmitEnabled.receive(on: RunLoop.main)) { enabled in
            isSubmitEnabled = enabled
        }
        .alert("Ошибка", isPresented: $isPresentingError) {
            Button("Ок", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert(successTitle, isPresented: $isPresentingSuccess) {
            Button("Ок", role: .cancel) {
                onFinish?()
            }
        } message: {
            Text(successMessage)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Private
    
    private func applyInitialValueFromViewModel() {
        let current = viewModel.currentValue
        
        switch fieldKind {
        case .phone:
            text = FormTextField.phoneDisplayText(e164: current, formatter: phoneFormatter)
        default:
            text = current
        }
    }
    
    private func submitTapped() {
        Task {
            do {
                try await viewModel.submit()
                
                switch fieldKind {
                case .email:
                    successTitle = Texts.emailSuccessTitle
                    successMessage = Texts.emailSuccessMessage
                    isPresentingSuccess = true
                    
                case .name:
                    successTitle = Texts.nameSuccessTitle
                    successMessage = Texts.nameSuccessMessage
                    isPresentingSuccess = true
                    
                case .phone:
                    successTitle = Texts.phoneSuccessTitle
                    successMessage = Texts.phoneSuccessMessage
                    isPresentingSuccess = true
                    
                default:
                    onFinish?()
                }
            } catch {
                errorMessage = (error as NSError).localizedDescription
                isPresentingError = true
            }
        }
    }
}

private extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
