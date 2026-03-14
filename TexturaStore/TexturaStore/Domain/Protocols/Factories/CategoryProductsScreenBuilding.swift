//
//  CategoryProductsScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

@MainActor
protocol CategoryProductsScreenBuilding {
    func makeCategoryProductsView(
        title: String,
        viewModel: CategoryProductsViewModelProtocol,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)?,
        onSelectProduct: ((Product) -> Void)?,
        onBack: (() -> Void)?
    ) -> AnyView
}
