//
//  CategoryProductsScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//


import SwiftUI

@MainActor
final class CategoryProductsScreenFactory: CategoryProductsScreenBuilding {

    func makeCategoryProductsView(
        title: String,
        viewModel: CategoryProductsViewModelProtocol,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)?,
        onSelectProduct: ((Product) -> Void)?,
        onBack: (() -> Void)?
    ) -> AnyView {
        AnyView(
            CategoryProductsView(
                title: title,
                viewModel: viewModel,
                languageProvider: languageProvider,
                localizer: localizer,
                onSelectProduct: onSelectProduct,
                onBack: onBack
            )
        )
    }
}
