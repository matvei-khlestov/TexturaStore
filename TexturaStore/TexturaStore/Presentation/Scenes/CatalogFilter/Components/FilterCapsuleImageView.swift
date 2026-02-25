//
//  FilterCapsuleImageView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 25.02.2026.
//

import SwiftUI
import Kingfisher

/// Картинка слева для капсулы категории/бренда.
/// Берёт изображение из `imageURL`.
struct FilterCapsuleImageView: View {
    
    // MARK: - Props
    
    let imageURL: String
    
    // MARK: - Body
    
    var body: some View {
        let url = URL(string: imageURL)
        
        KFImage(url)
            .placeholder {
                RoundedRectangle(cornerRadius: FilterCapsuleImageViewMetrics.Corners.placeholder)
                    .fill(Color(uiColor: .secondarySystemBackground))
            }
            .cacheOriginalImage()
            .fade(duration: 0.15)
            .resizable()
            .scaledToFill()
            .frame(
                width: FilterCapsuleImageViewMetrics.Sizes.side,
                height: FilterCapsuleImageViewMetrics.Sizes.side
            )
            .clipShape(RoundedRectangle(cornerRadius: FilterCapsuleImageViewMetrics.Corners.image))
            .overlay(
                RoundedRectangle(cornerRadius: FilterCapsuleImageViewMetrics.Corners.image)
                    .stroke(Color(uiColor: .separator), lineWidth: FilterCapsuleImageViewMetrics.Stroke.width)
            )
            .clipped()
            .accessibilityHidden(true)
    }
}

// MARK: - Metrics

private enum FilterCapsuleImageViewMetrics {
    enum Sizes {
        static let side: CGFloat = 26
    }
    enum Corners {
        static let image: CGFloat = 8
        static let placeholder: CGFloat = 8
    }
    enum Stroke {
        static let width: CGFloat = 0.8
    }
}
