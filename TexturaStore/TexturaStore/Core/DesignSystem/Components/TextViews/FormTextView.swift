//
//  FormTextView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import SwiftUI

/// Компонент `FormTextView`.
///
/// Отвечает за:
/// - многострочное поле с заголовком и плейсхолдером;
/// - показ ошибки под полем;
/// - ограничение длины текста (`maxLength`);
/// - фиксированную высоту контейнера (`fixedHeight`);
/// - обратный вызов при изменении текста.
///
/// Структура UI:
/// - `Text` — заголовок поля;
/// - `RoundedRectangle` — контейнер с рамкой и скруглением;
/// - `TextEditor` — ввод многострочного текста;
/// - `Text` — плейсхолдер внутри контейнера;
/// - `Text` — строка ошибки под контейнером;
/// - `VStack` — вертикальная компоновка.
///
/// Поведение:
/// - плейсхолдер скрывается при наличии текста;
/// - ошибка показывается после первого взаимодействия,
///   либо сразу при `forceShowError = true`;
/// - рамка контейнера меняет цвет/толщину при ошибке;
/// - поддерживается скролл внутри `TextEditor`.
///
/// Публичный API:
/// - `onTextChanged: (String) -> Void` — колбэк ввода;
/// - `maxLength: Int?` — лимит символов;
/// - `fixedHeight: CGFloat` — высота контейнера;
/// - `text: Binding<String>` — значение поля;
/// - `title: String?` — заголовок;
/// - `errorMessage: String?` — текст ошибки;
/// - `forceShowError: Bool` — принудительный показ ошибки.
///
/// Использование:
/// - комментарии к заказу на чекауте.
struct FormTextView: View {
    
    // MARK: - Public API
    
    let title: String?
    let placeholder: String?
    @Binding var text: String
    
    var errorMessage: String?
    var forceShowError: Bool = false
    var maxLength: Int?
    var fixedHeight: CGFloat = Metrics.Sizes.fixedHeight
    var onTextChanged: ((String) -> Void)?
    
    // MARK: - State
    
    @State private var hasInteracted = false
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.verticalStack) {
            if let title, !title.isEmpty {
                Text(title)
                    .font(Font(Metrics.Fonts.title))
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(1)
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Metrics.Corners.container)
                    .fill(Color(Metrics.Colors.bg))
                    .overlay(
                        RoundedRectangle(cornerRadius: Metrics.Corners.container)
                            .stroke(
                                shouldShowError
                                ? Color(cgColor: Metrics.Colors.borderError)
                                : Color(cgColor: Metrics.Colors.borderNormal),
                                lineWidth: shouldShowError
                                ? Metrics.Sizes.borderErrorWidth
                                : Metrics.Sizes.borderNormalWidth
                            )
                    )
                
                if #available(iOS 16.0, *) {
                    TextEditor(text: bindingText)
                        .font(Font(Metrics.Fonts.text))
                        .foregroundStyle(Color(Metrics.Colors.text))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, Metrics.Insets.content.left - 4)
                        .padding(.vertical, Metrics.Insets.content.top - 8)
                        .frame(height: fixedHeight)
                        .focused($isFocused)
                        .onChange(of: isFocused) { focused in
                            if focused, !hasInteracted {
                                hasInteracted = true
                            }
                        }
                } else {
                    // Fallback on earlier versions
                }
                
                if trimmedText.isEmpty, let placeholder, !placeholder.isEmpty {
                    Text(placeholder)
                        .font(Font(Metrics.Fonts.placeholder))
                        .foregroundStyle(Color(Metrics.Colors.placeholder))
                        .padding(.leading, Metrics.Insets.content.left + 1)
                        .padding(.top, Metrics.Insets.content.top + 1)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: fixedHeight)
            
            Text(shouldShowError ? (errorMessage ?? "") : "")
                .font(Font(Metrics.Fonts.error))
                .foregroundStyle(Color(Metrics.Colors.error))
                .lineLimit(1)
                .frame(height: Metrics.Sizes.errorHeight, alignment: .topLeading)
                .opacity(shouldShowError ? 1 : 0)
        }
        .background(Color.clear)
    }
}

// MARK: - Helpers

private extension FormTextView {
    
    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var shouldShowError: Bool {
        let hasError = !(errorMessage?.isEmpty ?? true)
        return hasError && (forceShowError || hasInteracted)
    }
    
    var bindingText: Binding<String> {
        Binding(
            get: { text },
            set: { newValue in
                let limitedValue: String
                if let maxLength {
                    limitedValue = String(newValue.prefix(maxLength))
                } else {
                    limitedValue = newValue
                }
                
                text = limitedValue
                onTextChanged?(limitedValue)
            }
        )
    }
}

// MARK: - Metrics

private extension FormTextView {
    
    enum Metrics {
        enum Insets {
            static let content: UIEdgeInsets = .init(
                top: 10,
                left: 12,
                bottom: 10,
                right: 12
            )
        }
        
        enum Spacing {
            static let verticalStack: CGFloat = 6
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let placeholder: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let text: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let error: UIFont = .systemFont(ofSize: 13, weight: .regular)
        }
        
        enum Sizes {
            static let fixedHeight: CGFloat = 120
            static let errorHeight: CGFloat = 16
            static let borderErrorWidth: CGFloat = 1.0
            static let borderNormalWidth: CGFloat = 0.5
        }
        
        enum Corners {
            static let container: CGFloat = 10
        }
        
        enum Colors {
            static let bg: UIColor = .secondarySystemBackground
            static let text: UIColor = .label
            static let placeholder: UIColor = .secondaryLabel
            static let error: UIColor = .systemRed
            static let borderNormal: CGColor = UIColor.systemGray.cgColor
            static let borderError: CGColor = UIColor.systemRed.withAlphaComponent(0.6).cgColor
        }
    }
}
