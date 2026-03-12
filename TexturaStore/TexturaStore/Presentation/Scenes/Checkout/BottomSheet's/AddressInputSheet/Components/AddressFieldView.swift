//
//  AddressFieldView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

struct AddressFieldView: View {
    
    // MARK: - Properties
    
    let title: String
    let placeholder: String
    @Binding var text: String
    let error: String?
    let keyboardType: UIKeyboardType
    let onTextChanged: ((String) -> Void)?
    
    // MARK: - State
    
    @State private var hasInteracted = false
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Spacing {
            static let vertical: CGFloat = 6
        }
        
        enum Sizes {
            static let fieldHeight: CGFloat = 48
        }
        
        enum Insets {
            static let horizontal: CGFloat = 12
        }
        
        enum Line {
            static let errorHeight: CGFloat = 16
            static let borderErrorWidth: CGFloat = 1.0
            static let borderNormalWidth: CGFloat = 0.5
        }
        
        enum Corners {
            static let field: CGFloat = 12
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.vertical) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)
            
            TextField(
                placeholder,
                text: Binding(
                    get: { text },
                    set: { newValue in
                        if !hasInteracted { hasInteracted = true }
                        text = newValue
                        onTextChanged?(newValue)
                    }
                )
            )
            .padding(.horizontal, Metrics.Insets.horizontal)
            .frame(height: Metrics.Sizes.fieldHeight)
            .background(Color(.secondarySystemBackground))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Metrics.Corners.field,
                    style: .continuous
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: Metrics.Corners.field,
                    style: .continuous
                )
                .strokeBorder(
                    errorToShow == nil
                    ? Color(.secondarySystemFill)
                    : Color.red.opacity(0.6),
                    lineWidth: errorToShow == nil
                    ? Metrics.Line.borderNormalWidth
                    : Metrics.Line.borderErrorWidth
                )
            )
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(false)
            
            Text(errorToShow ?? "")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.red)
                .lineLimit(1)
                .opacity(errorToShow == nil ? 0 : 1)
                .frame(height: Metrics.Line.errorHeight, alignment: .leading)
        }
    }
    
    private var errorToShow: String? {
        guard let error, !error.isEmpty else { return nil }
        return hasInteracted ? error : nil
    }
}
