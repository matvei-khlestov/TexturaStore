//
//  ReviewPreviewCard.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import SwiftUI

struct ReviewPreviewCard: View {
    
    let review: ProductReview
    
    private enum Metrics {
        enum Insets {
            static let content: CGFloat = 16
        }
        
        enum Sizes {
            static let width: CGFloat = 240
            static let height: CGFloat = 200
        }
        
        enum Corners {
            static let card: CGFloat = 16
        }
        
        enum Spacing {
            static let content: CGFloat = 12
            static let header: CGFloat = 8
        }
        
        enum Fonts {
            static let name: CGFloat = 16
            static let rating: CGFloat = 16
            static let text: CGFloat = 15
            static let star: CGFloat = 16
        }
        
        enum Lines {
            static let preview: Int = 6
        }
    }
    
    private enum Symbols {
        static let starFilled = "star.fill"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.content) {
            HStack(alignment: .top, spacing: Metrics.Spacing.header) {
                Text(review.userName)
                    .font(.system(size: Metrics.Fonts.name, weight: .bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: Symbols.starFilled)
                        .font(.system(size: Metrics.Fonts.star, weight: .semibold))
                        .foregroundStyle(Color.brand)
                    
                    Text("\(review.rating)")
                        .font(.system(size: Metrics.Fonts.rating, weight: .medium))
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
            
            Text((review.comment ?? "").isEmpty ? "—" : (review.comment ?? ""))
                .font(.system(size: Metrics.Fonts.text, weight: .regular))
                .foregroundStyle(Color(uiColor: .label))
                .lineLimit(Metrics.Lines.preview)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(Metrics.Insets.content)
        .frame(
            width: Metrics.Sizes.width,
            height: Metrics.Sizes.height,
            alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: Metrics.Corners.card, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}
