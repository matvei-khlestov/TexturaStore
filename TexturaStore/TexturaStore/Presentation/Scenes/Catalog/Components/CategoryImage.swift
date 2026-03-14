//
//  CategoryImage.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import SwiftUI
import Kingfisher

struct CategoryImage: View {
    
    let urlString: String
    
    var body: some View {
        let url = URL(string: urlString)
        
        KFImage(url)
            .placeholder {
                Color(uiColor: .secondarySystemBackground)
            }
            .cancelOnDisappear(true)
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .background(Circle().fill(Color(uiColor: .secondarySystemBackground)))
    }
}
