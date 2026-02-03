//
//  BrandNavigationBackButtonModifier.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

private struct BrandNavigationBackButtonModifier: ViewModifier {
    
    let onBack: () -> Void
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BrandBackButton(onTap: onBack)
                }
            }
    }
}

extension View {
    
    func brandBackButton(onBack: @escaping () -> Void) -> some View {
        modifier(BrandNavigationBackButtonModifier(onBack: onBack))
    }
}
