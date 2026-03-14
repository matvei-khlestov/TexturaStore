//
//  CatalogScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import SwiftUI

@MainActor
protocol CatalogScreenBuilding {
    
    // MARK: - Catalog
    
    func makeCatalogView(
        viewModel: CatalogViewModelProtocol,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)?,
        onSelectProduct: ((Product) -> Void)?,
        onFilterTap: ((FilterState) -> Void)?,
        onSelectCategory: ((Category) -> Void)?
    ) -> AnyView
    
    // MARK: - Catalog Filter
    
    func makeCatalogFilterView(
        viewModel: any CatalogFilterViewModelProtocol,
        initialState: FilterState,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)?,
        onBack: (() -> Void)?,
        onApply: ((FilterState) -> Void)?
    ) -> AnyView
}
