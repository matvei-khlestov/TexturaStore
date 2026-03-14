//
//  FavoritesScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

@MainActor
protocol FavoritesScreenBuilding {
    func makeFavoritesView(
        viewModel: FavoritesViewModelProtocol,
        onSelectProduct: ((String) -> Void)?
    ) -> AnyView
}
