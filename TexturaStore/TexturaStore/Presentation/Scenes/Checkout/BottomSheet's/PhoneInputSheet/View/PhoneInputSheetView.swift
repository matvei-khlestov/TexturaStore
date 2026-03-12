//
//  PhoneInputSheetView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import SwiftUI
import Combine

/// View `PhoneInputSheetView`
/// для экрана ввода номера получателя.
///
/// Основные задачи:
/// - отображение и редактирование телефона через `FormTextField`;
/// - реактивный биндинг с `PhoneInputSheetViewModelProtocol` (Combine);
/// - отображение ошибок валидации в UI;
/// - сохранение введённого номера при нажатии на кнопку.
///
/// Взаимодействует с:
/// - `PhoneInputSheetViewModelProtocol` — хранение состояния и валидация телефона;
/// - `PhoneFormattingProtocol` — форматирование номера в E.164 и человекочитаемом виде.
///
/// Особенности:
/// - при вводе номера автоматически применяется маска `+7`;
/// - валидация выполняется при сохранении;
/// - при ошибке шит остаётся открытым.
struct PhoneInputSheetView: View {
    
    // MARK: - VM
    
    private let viewModel: any PhoneInputSheetViewModelProtocol
    private let phoneFormatter: any PhoneFormattingProtocol
    
    // MARK: - Callback
    
    var onSavePhone: ((String) -> Void)?
    
    // MARK: - State
    
    @State private var phoneText: String = ""
    @State private var errorMessage: String?
    
    // MARK: - Env
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let buttonHeight: CGFloat = 52
            static let buttonCornerRadius: CGFloat = 16
        }
        
        enum Insets {
            static let horizontal: CGFloat = 16
            static let top: CGFloat = 20
            static let bottom: CGFloat = 20
        }
        
        enum Spacing {
            static let content: CGFloat = 16
        }
    }
    
    // MARK: - Init
    
    init(
        viewModel: any PhoneInputSheetViewModelProtocol,
        phoneFormatter: any PhoneFormattingProtocol,
        onSavePhone: ((String) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.phoneFormatter = phoneFormatter
        self.onSavePhone = onSavePhone
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.content) {
            FormTextField(
                kind: .phone,
                text: $phoneText,
                error: errorMessage,
                phoneFormatter: phoneFormatter,
                onTextChanged: { e164 in
                    viewModel.setPhone(e164)
                }
            )
            
            Button(action: saveTapped) {
                Text(L10n.PhoneInput.save)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Metrics.Sizes.buttonHeight)
                    .background(
                        RoundedRectangle(
                            cornerRadius: Metrics.Sizes.buttonCornerRadius,
                            style: .continuous
                        )
                        .fill(Color(uiColor: .brand))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Metrics.Insets.horizontal)
        .padding(.top, Metrics.Insets.top)
        .padding(.bottom, Metrics.Insets.bottom)
        .navigationTitle(L10n.PhoneInput.Navigation.title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(viewModel.phonePublisher.removeDuplicates()) { e164 in
            let seed = e164.isEmpty ? "+7" : e164
            phoneText = FormTextField.phoneDisplayText(
                e164: seed,
                formatter: phoneFormatter
            )
        }
        .onReceive(viewModel.errorPublisher) { message in
            errorMessage = message
        }
        .onAppear {
            let seed = viewModel.phone.isEmpty ? "+7" : viewModel.phone
            phoneText = FormTextField.phoneDisplayText(
                e164: seed,
                formatter: phoneFormatter
            )
        }
    }
}

// MARK: - Actions

private extension PhoneInputSheetView {
    
    func saveTapped() {
        if viewModel.validate() {
            onSavePhone?(viewModel.phone)
            dismiss()
        }
    }
}
