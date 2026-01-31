//
//  DesignSystem.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI

enum DesignSystem {

    // MARK: - Colors
    
    enum Colors {
        static let brandPrimary = Color("brandColor")
        static let background = Color("Background")
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
    }

    // MARK: - Fonts
    
    enum Fonts {
        static let title = Font.system(size: 24, weight: .bold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
    }

    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Radius
    
    enum Radius {
        static let card: CGFloat = 16
        static let button: CGFloat = 12
        static let image: CGFloat = 8
    }
}
