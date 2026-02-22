//
//  CategoryItemView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI
import Kingfisher

struct CategoryItemView: View {
    
    let title: String
    let imageURL: String
    let count: Int
    
    private enum Metrics {
        static let width: CGFloat = 88
        static let imageSide: CGFloat = 64
        static let titleSize: CGFloat = 15
        static let subtitleSize: CGFloat = 12
        static let spacingImageToTitle: CGFloat = 6
        static let spacingTitleToSubtitle: CGFloat = 2
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CircleImage(urlString: imageURL)
                .frame(width: Metrics.imageSide, height: Metrics.imageSide)
            
            Text(title)
                .font(.system(size: Metrics.titleSize, weight: .semibold))
                .foregroundStyle(Color(uiColor: .label))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.top, Metrics.spacingImageToTitle)
            
            Text(L10n.Catalog.Category.Products.count(count))
                .font(.system(size: Metrics.subtitleSize, weight: .regular))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .lineLimit(1)
                .padding(.top, Metrics.spacingTitleToSubtitle)
        }
        .frame(width: Metrics.width)
    }
}

struct CircleImage: View {
    
    let urlString: String
    
    var body: some View {
        let url = URL(string: urlString)
        
        KFImage(url)
            .placeholder { Color(uiColor: .secondarySystemBackground) }
            .cancelOnDisappear(true)
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .background(Circle().fill(Color(uiColor: .secondarySystemBackground)))
    }
}
