//
//  PriceRangeFieldsView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

/// SwiftUI-аналог `PriceFieldCell`: два поля «Мин. цена» и «Макс. цена» с валидацией ввода.
struct PriceRangeFieldsView: View {
    
    // MARK: - Props
    
    let minPlaceholder: String
    let maxPlaceholder: String
    
    @Binding var minText: String
    @Binding var maxText: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Metrics.Spacing.fieldsGap) {
            field(placeholder: minPlaceholder, text: $minText)
            field(placeholder: maxPlaceholder, text: $maxText)
        }
        .padding(.top, Metrics.Spacing.top)
    }
}

// MARK: - UI

private extension PriceRangeFieldsView {
    
    func field(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: Metrics.Fonts.textSize, weight: .semibold))
            .foregroundStyle(Color(uiColor: .label))
            .keyboardType(.decimalPad)
            .padding(.horizontal, Metrics.Insets.leftRight)
            .frame(minHeight: Metrics.Sizes.fieldHeight)
            .background(
                RoundedRectangle(cornerRadius: Metrics.Corners.container)
                    .fill(Color(uiColor: Metrics.Colors.background))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.Corners.container)
                    .stroke(Color(uiColor: Metrics.Colors.border), lineWidth: Metrics.Sizes.borderWidth)
            )
            .onChange(of: text.wrappedValue) { newValue in
                let normalized = Self.normalizeAndFilter(newValue)
                if normalized != newValue {
                    text.wrappedValue = normalized
                }
            }
            .accessibilityLabel(Text(placeholder))
    }
}

// MARK: - Helpers

private extension PriceRangeFieldsView {
    
    static func normalizeAndFilter(_ value: String) -> String {
        // 1) trim
        var t = value.trimmingCharacters(in: .whitespacesAndNewlines)
        // 2) comma -> dot
        t = t.replacingOccurrences(of: ",", with: ".")
        // 3) allow only digits + dot
        t = t.filter { $0.isNumber || $0 == "." }
        // 4) only one dot
        var dotCount = 0
        t = t.filter {
            if $0 == "." {
                dotCount += 1
                return dotCount <= 1
            }
            return true
        }
        return t
    }
}

// MARK: - Metrics

private extension PriceRangeFieldsView {
    
    enum Metrics {
        enum Sizes {
            static let fieldHeight: CGFloat = 44
            static let borderWidth: CGFloat = 1
        }
        
        enum Corners {
            static let container: CGFloat = 12
        }
        
        enum Insets {
            static let leftRight: CGFloat = 12
        }
        
        enum Spacing {
            static let fieldsGap: CGFloat = 12
            static let top: CGFloat = 8
        }
        
        enum Fonts {
            static let textSize: CGFloat = 16
        }
        
        enum Colors {
            static let background: UIColor = .secondarySystemBackground
            static let border: UIColor = .separator
        }
    }
}
