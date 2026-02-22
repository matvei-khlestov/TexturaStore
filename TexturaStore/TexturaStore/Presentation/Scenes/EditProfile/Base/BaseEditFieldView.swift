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
                title: L10n.Profile.EditField.submit,
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
        .alert(L10n.Common.Error.title, isPresented: $isPresentingError) {
            Button(L10n.Common.ok, role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert(successTitle, isPresented: $isPresentingSuccess) {
            Button(L10n.Common.ok, role: .cancel) {
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
                    successTitle = L10n.Profile.EditField.Email.Success.title
                    successMessage = L10n.Profile.EditField.Email.Success.message
                    isPresentingSuccess = true
                    
                case .name:
                    successTitle = L10n.Profile.EditField.Name.Success.title
                    successMessage = L10n.Profile.EditField.Name.Success.message
                    isPresentingSuccess = true
                    
                case .phone:
                    successTitle = L10n.Profile.EditField.Phone.Success.title
                    successMessage = L10n.Profile.EditField.Phone.Success.message
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
