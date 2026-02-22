//
//  FavoritesScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

@MainActor
final class FavoritesScreenFactory: FavoritesScreenBuilding {
    
    func makeFavoritesView(
        viewModel: FavoritesViewModelProtocol,
        onSelectProduct: ((String) -> Void)?
    ) -> AnyView {
        AnyView(
            FavoritesView(
                viewModel: viewModel,
                onSelectProduct: onSelectProduct
            )
        )
    }
}
