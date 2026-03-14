//
//  FormTextField.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import SwiftUI

/// Компонент `FormTextField`.
///
/// Отвечает за:
/// - поле ввода с заголовком и ошибкой;
/// - типы: `name`, `email`, `password`, `phone`;
/// - работу кнопки «глаз» для пароля;
/// - маску и нормализацию телефона.
///
/// Структура UI:
/// - `Text` — заголовок поля;
/// - `TextField` / `SecureField` — ввод;
/// - `Button` — «глаз» (для пароля);
/// - `Text` — строка ошибки;
/// - `VStack` — вертикальная компоновка.
///
/// Поведение:
/// - вызывает `onTextChanged` при изменении текста;
/// - ошибки показываются после первого ввода;
/// - для пароля поддерживается переключение secure;
/// - телефон форматируется через `PhoneFormattingProtocol`.
///
/// Публичный API:
/// - `text` — биндинг значения;
/// - `error` — сообщение ошибки (опционально);
/// - `onTextChanged: (String) -> Void` — колбэк ввода;
/// - `phoneFormatter` — форматирование телефона (опционально).
struct FormTextField: View {
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Spacing {
            static let vertical: CGFloat = 6
        }
        
        enum Sizes {
            static let textFieldHeight: CGFloat = 48
            static let rightViewWidth: CGFloat = 44
        }
        
        enum Insets {
            static let textFieldLeft: CGFloat = 12
        }
        
        enum Line {
            static let errorHeight: CGFloat = 16
            static let borderErrorWidth: CGFloat = 1.0
            static let borderNormalWidth: CGFloat = 0.5
        }
        
        enum CornerRadius {
            static let textField: CGFloat = 12
        }
    }
    
    // MARK: - Dependencies
    
    private let kind: FormTextFieldKind
    private let phoneFormatter: PhoneFormattingProtocol?
    
    // MARK: - Public API
    
    @Binding private var text: String
    private let error: String?
    private let onTextChanged: ((String) -> Void)?
    
    // MARK: - State
    
    @State private var hasInteracted: Bool = false
    @State private var isSecure: Bool = true
    
    // MARK: - Init
    
    init(
        kind: FormTextFieldKind,
        text: Binding<String>,
        error: String? = nil,
        phoneFormatter: PhoneFormattingProtocol? = nil,
        onTextChanged: ((String) -> Void)? = nil
    ) {
        self.kind = kind
        self._text = text
        self.error = error
        self.phoneFormatter = phoneFormatter
        self.onTextChanged = onTextChanged
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.vertical) {
            Text(kind.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)
            
            field
                .frame(height: Metrics.Sizes.textFieldHeight)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: Metrics.CornerRadius.textField, style: .continuous))
                .overlay(borderOverlay)
            
            errorRow
        }
        .onAppear {
            applyInitialPhoneTextIfNeeded()
        }
    }
    
    // MARK: - Field
    
    @ViewBuilder
    private var field: some View {
        switch kind {
        case .password:
            passwordField
        case .phone:
            phoneField
        default:
            regularField
        }
    }
    
    private var regularField: some View {
        TextField(
            kind.placeholder,
            text: Binding(
                get: { text },
                set: { newValue in
                    markInteractedIfNeeded()
                    text = newValue
                    onTextChanged?(newValue)
                }
            )
        )
        .padding(.horizontal, Metrics.Insets.textFieldLeft)
        .font(.system(size: 16, weight: .regular))
        .foregroundStyle(Color.primary)
        .textInputAutocapitalization(autocapitalization(for: kind))
        .autocorrectionDisabled(autocorrectionDisabled(for: kind))
        .keyboardType(keyboardType(for: kind))
        .textContentType(textContentType(for: kind))
        .submitLabel(submitLabel(for: kind))
    }
    
    private var passwordField: some View {
        HStack(spacing: 0) {
            Group {
                if isSecure {
                    SecureField(
                        kind.placeholder,
                        text: Binding(
                            get: { text },
                            set: { newValue in
                                markInteractedIfNeeded()
                                text = newValue
                                onTextChanged?(newValue)
                            }
                        )
                    )
                } else {
                    TextField(
                        kind.placeholder,
                        text: Binding(
                            get: { text },
                            set: { newValue in
                                markInteractedIfNeeded()
                                text = newValue
                                onTextChanged?(newValue)
                            }
                        )
                    )
                }
            }
            .padding(.leading, Metrics.Insets.textFieldLeft)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(Color.primary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .keyboardType(.asciiCapable)
            .textContentType(.oneTimeCode)
            .submitLabel(.done)
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundStyle(Color.secondary)
                    .frame(width: Metrics.Sizes.rightViewWidth, height: Metrics.Sizes.textFieldHeight)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var phoneField: some View {
        TextField(
            kind.placeholder,
            text: Binding(
                get: { text },
                set: { newValue in
                    markInteractedIfNeeded()
                    text = applyPhoneFormat(fromDisplayInput: newValue)
                }
            )
        )
        .padding(.horizontal, Metrics.Insets.textFieldLeft)
        .font(.system(size: 16, weight: .regular))
        .foregroundStyle(Color.primary)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .keyboardType(.numberPad)
        .textContentType(.telephoneNumber)
        .submitLabel(.done)
        .onTapGesture {
            if text.isEmpty {
                applyInitialPhoneTextIfNeeded()
            }
        }
    }
    
    // MARK: - Error UI
    
    private var errorRow: some View {
        Text(errorToShow ?? "")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(Color.red)
            .lineLimit(1)
            .opacity(errorToShow == nil ? 0 : 1)
            .frame(height: Metrics.Line.errorHeight, alignment: .leading)
    }
    
    private var errorToShow: String? {
        guard let error, !error.isEmpty else { return nil }
        return hasInteracted ? error : nil
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: Metrics.CornerRadius.textField, style: .continuous)
            .strokeBorder(borderColor, lineWidth: borderWidth)
    }
    
    private var borderColor: Color {
        errorToShow == nil ? Color(.secondarySystemFill) : Color.red.opacity(0.6)
    }
    
    private var borderWidth: CGFloat {
        errorToShow == nil ? Metrics.Line.borderNormalWidth : Metrics.Line.borderErrorWidth
    }
    
    private func markInteractedIfNeeded() {
        if !hasInteracted { hasInteracted = true }
    }
    
    // MARK: - Phone behavior
    
    private func applyInitialPhoneTextIfNeeded() {
        guard kind == .phone else { return }
        
        if let phoneFormatter {
            if text.isEmpty {
                text = phoneFormatter.displayForTextField(nil)
            } else {
                if text.hasPrefix("+7"), phoneFormatter.digits(from: text).count >= 11 {
                    text = phoneFormatter.displayForTextField(text)
                }
            }
        } else {
            if text.isEmpty { text = "+7" }
        }
    }
    
    private func applyPhoneFormat(fromDisplayInput displayInput: String) -> String {
        guard let phoneFormatter else {
            onTextChanged?(displayInput)
            return displayInput
        }
        
        var digits = phoneFormatter.digits(from: displayInput)
        if digits.isEmpty { digits = "7" }
        
        let formatted = phoneFormatter.formatRussianPhone(digits)
        onTextChanged?(formatted.e164)
        return formatted.display
    }
    
    // MARK: - Config helpers
    
    private func autocapitalization(for kind: FormTextFieldKind) -> TextInputAutocapitalization {
        switch kind {
        case .name:
            return .words
        case .email, .password, .phone:
            return .never
        }
    }
    
    private func autocorrectionDisabled(for kind: FormTextFieldKind) -> Bool {
        switch kind {
        case .email, .password, .phone:
            return true
        case .name:
            return false
        }
    }
    
    private func keyboardType(for kind: FormTextFieldKind) -> UIKeyboardType {
        switch kind {
        case .name:
            return .default
        case .email:
            return .emailAddress
        case .password:
            return .asciiCapable
        case .phone:
            return .numberPad
        }
    }
    
    private func textContentType(for kind: FormTextFieldKind) -> UITextContentType? {
        switch kind {
        case .name:
            return .name
        case .email:
            return .emailAddress
        case .password:
            return .oneTimeCode
        case .phone:
            return .telephoneNumber
        }
    }
    
    private func submitLabel(for kind: FormTextFieldKind) -> SubmitLabel {
        switch kind {
        case .name, .email:
            return .next
        case .password, .phone:
            return .done
        }
    }
}

// MARK: - Phone API

extension FormTextField {
    static func phoneDisplayText(e164: String?, formatter: PhoneFormattingProtocol?) -> String {
        guard let formatter else { return e164 ?? "" }
        return formatter.displayForTextField(e164)
    }
}
