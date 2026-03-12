//
//  StatusBadgeView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

/// SwiftUI-бейдж статуса заказа.
struct StatusBadgeView: View {
    
    let text: String
    let color: UIColor
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(uiColor: color))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(uiColor: color).opacity(0.12))
            .clipShape(Capsule())
    }
}
