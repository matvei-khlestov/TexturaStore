//
//  ProductImage.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import SwiftUI
import Kingfisher

struct ProductImage: View {
    
    let urlString: String
    
    var body: some View {
        let url = URL(string: urlString)
        
        KFImage(url)
            .placeholder { Color(uiColor: .secondarySystemBackground) }
            .cacheOriginalImage()
            .fade(duration: 0.15)
            .resizable()
            .scaledToFill()
            .clipped()
    }
}
