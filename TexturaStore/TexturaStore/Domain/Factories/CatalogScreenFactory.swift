//
//  CatalogScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import SwiftUI

@MainActor
final class CatalogScreenFactory: CatalogScreenBuilding {
    
    func makeCatalogView(
        viewModel: CatalogViewModelProtocol,
        onSelectProduct: ((Product) -> Void)?,
        onFilterTap: ((FilterState) -> Void)?,
        onSelectCategory: ((Category) -> Void)?
    ) -> AnyView {
        AnyView(
            CatalogView(
                viewModel: viewModel,
                onSelectProduct: onSelectProduct,
                onFilterTap: onFilterTap,
                onSelectCategory: onSelectCategory
            )
        )
    }
}
