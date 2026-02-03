//
//  PrivacyPolicyView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI
import UIKit

/// Экран `PrivacyPolicyView` для "Политики конфиденциальности".
///
/// Отвечает за:
/// - отображение текста политики конфиденциальности в виде прокручиваемого контента;
/// - применение форматирования абзацев с заданным интервалом и межстрочным расстоянием;
/// - настройку навигационной панели с кнопкой «Назад»;
/// - обработку нажатия на кнопку для закрытия экрана.
///
/// Особенности:
/// - текст не редактируем, но доступен для выделения и копирования;
/// - поддерживает Dynamic Type и адаптивные отступы;
/// - текст форматируется через `NSMutableParagraphStyle`.
struct PrivacyPolicyView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 16
            static let verticalBottom: CGFloat = 24
        }
        
        enum Fonts {
            static let body: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
        
        enum Paragraph {
            static let lineSpacing: CGFloat = 2
            static let paragraphSpacing: CGFloat = 6
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = L10n.Auth.Signup.privacyTitle
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.vertical) {
            Text(attributedPolicyText)
                .foregroundStyle(Color.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Metrics.Insets.verticalTop)
                .padding(.horizontal, Metrics.Insets.horizontal)
                .padding(.bottom, Metrics.Insets.verticalBottom)
        }
        .background(Color(.systemBackground))
        .navigationTitle(Texts.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton {
            onBack?()
        }
        .accessibilityIdentifier("privacy.screen")
    }
    
    // MARK: - Content
    
    private var attributedPolicyText: AttributedString {
        let ns = makeAttributedPolicyText(PrivacyPolicyText.body)
        return (try? AttributedString(ns, including: \.uiKit)) ?? AttributedString(PrivacyPolicyText.body)
    }
    
    private func makeAttributedPolicyText(_ text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Metrics.Paragraph.lineSpacing
        paragraph.paragraphSpacing = Metrics.Paragraph.paragraphSpacing
        
        return NSAttributedString(
            string: text,
            attributes: [
                .font: Metrics.Fonts.body,
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraph
            ]
        )
    }
}
