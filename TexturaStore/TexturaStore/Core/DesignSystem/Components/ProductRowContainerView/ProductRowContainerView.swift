//
//  ProductRowContainerView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI
import Kingfisher

struct ProductRowContainerView<BottomContent: View>: View {
    
    // MARK: - Dependencies
    
    let imageURL: String?
    let imageHeight: CGFloat
    
    let brandName: String
    let title: String
    let priceText: String
    
    @ViewBuilder let bottomContent: () -> BottomContent
    
    // MARK: - Init
    
    init(
        imageURL: String?,
        imageHeight: CGFloat,
        brandName: String,
        title: String,
        priceText: String,
        @ViewBuilder bottomContent: @escaping () -> BottomContent
    ) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.brandName = brandName
        self.title = title
        self.priceText = priceText
        self.bottomContent = bottomContent
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: Constants.Metrics.spacing) {
            ProductRowImageView(
                urlString: imageURL,
                width: Constants.Metrics.imageWidth,
                height: imageHeight,
                cornerRadius: Constants.Metrics.cornerRadius
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(brandName)
                    .font(.system(size: Constants.Metrics.brandFontSize, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(Constants.Metrics.brandLineLimit)
                
                Text(title)
                    .font(.system(size: Constants.Metrics.titleFontSize, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(Constants.Metrics.titleLineLimit)
                
                Text(priceText)
                    .font(.system(size: Constants.Metrics.priceFontSize, weight: .bold))
                    .foregroundStyle(Color(uiColor: .brand))
                
                HStack(spacing: 8) {
                    bottomContent()
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.vertical, Constants.Metrics.verticalPadding)
    }
}

// MARK: - Subviews

private struct ProductRowImageView: View {
    
    let urlString: String?
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        KFImage(URL(string: urlString ?? ""))
            .placeholder {
                Color.secondary.opacity(0.15)
            }
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Constants

private enum Constants {
    enum Metrics {
        static let imageWidth: CGFloat = 108
        static let cornerRadius: CGFloat = 12
        static let spacing: CGFloat = 12
        
        static let brandFontSize: CGFloat = 13
        static let titleFontSize: CGFloat = 16
        static let priceFontSize: CGFloat = 18
        
        static let titleLineLimit: Int = 2
        static let brandLineLimit: Int = 1
        
        static let verticalPadding: CGFloat = 12
    }
}
