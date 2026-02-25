//
//  CatalogScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import SwiftUI

@MainActor
final class CatalogScreenFactory: CatalogScreenBuilding {
    
    // MARK: - Catalog
    
    func makeCatalogView(
        viewModel: CatalogViewModelProtocol,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)?,
        onSelectProduct: ((Product) -> Void)?,
        onFilterTap: ((FilterState) -> Void)?,
        onSelectCategory: ((Category) -> Void)?
    ) -> AnyView {
        AnyView(
            CatalogView(
                viewModel: viewModel,
                languageProvider: languageProvider,
                localizer: localizer,
                onSelectProduct: onSelectProduct,
                onFilterTap: onFilterTap,
                onSelectCategory: onSelectCategory
            )
        )
    }
    
    // MARK: - Catalog Filter
    
    func makeCatalogFilterView(
        viewModel: any CatalogFilterViewModelProtocol,
        initialState: FilterState,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)?,
        onBack: (() -> Void)?,
        onApply: ((FilterState) -> Void)?
    ) -> AnyView {
        AnyView(
            CatalogFilterView(
                viewModel: viewModel,
                initialState: initialState,
                languageProvider: languageProvider,
                localizer: localizer,
                onBack: onBack,
                onApply: onApply
            )
        )
    }
}
