//
//  LabelLinkRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import SwiftUI

/// Компонент `LabelLinkRow`.
///
/// Отвечает за:
/// - отображение пары "текст + кнопка-ссылка";
/// - вызов обработчика `onTap` при нажатии;
/// - поддержку выравнивания текста.
///
/// Структура UI:
/// - `Text` — обычный текст;
/// - `UnderlinedButton` — кликабельная ссылка;
/// - `HStack` — горизонтальное размещение элементов.
///
/// Публичный API:
/// - `onTap` — обработчик нажатия на ссылку;
/// - `init(label:button:alignment:onTap:)` — инициализация с параметрами.
struct LabelLinkRow: View {
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Spacing {
            static let hSpacing: CGFloat = 6
        }
    }
    
    // MARK: - Public API
    
    private let label: String
    private let button: String
    private let alignment: TextAlignment
    private let onTap: (() -> Void)?
    
    // MARK: - Init
    
    init(
        label: String,
        button: String,
        alignment: TextAlignment = .center,
        onTap: (() -> Void)? = nil
    ) {
        self.label = label
        self.button = button
        self.alignment = alignment
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: Metrics.Spacing.hSpacing) {
            Text(label)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(alignment)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            UnderlinedButton(
                text: button,
                alignment: alignmentToHorizontalAlignment(alignment)
            ) {
                onTap?()
            }
        }
        .frame(maxWidth: .infinity, alignment: alignmentToFrameAlignment(alignment))
    }
    
    // MARK: - Alignment helpers
    
    private func alignmentToHorizontalAlignment(_ alignment: TextAlignment) -> HorizontalAlignment {
        switch alignment {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .center
        }
    }
    
    private func alignmentToFrameAlignment(_ alignment: TextAlignment) -> Alignment {
        switch alignment {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .center
        }
    }
}
