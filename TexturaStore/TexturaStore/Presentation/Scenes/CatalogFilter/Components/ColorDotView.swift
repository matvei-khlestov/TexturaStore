//
//  ColorDotView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

/// Круглая плашка цвета для фильтра.
struct ColorDotView: View {
    
    // MARK: - Props
    
    let hex: String
    
    // MARK: - Body
    
    var body: some View {
        Circle()
            .fill(Color(hex: hex) ?? Color(uiColor: .clear))
            .frame(width: Metrics.size, height: Metrics.size)
            .overlay(
                Circle().stroke(
                    Color(uiColor: .separator),
                    lineWidth: Metrics.stroke
                )
            )
            .accessibilityHidden(true)
    }
}

// MARK: - Metrics

private extension ColorDotView {
    
    enum Metrics {
        static let size: CGFloat = 18
        static let stroke: CGFloat = 1
    }
}
