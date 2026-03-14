//
//  BrandBackButton.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

struct BrandBackButton: View {
    
    // MARK: - Props
    
    let onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: "chevron.left")
                .foregroundStyle(Color(.brand))
        }
    }
}
