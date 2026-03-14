//
//  CategoryProductsNavigator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

@MainActor
final class CategoryProductsNavigator: CategoryProductsNavigating {
    
    // MARK: - Deps
    
    private let categoryProductsScreenFactory: any CategoryProductsScreenBuilding
    private let authService: AuthServiceProtocol
    private let makeCategoryProductsViewModel: (String, String) -> any CategoryProductsViewModelProtocol
    
    private let languageProvider: any LanguageProviding
    private let localizer: any CatalogLocalizing
    
    // MARK: - Init
    
    init(
        categoryProductsScreenFactory: any CategoryProductsScreenBuilding,
        authService: AuthServiceProtocol,
        makeCategoryProductsViewModel: @escaping (String, String) -> any CategoryProductsViewModelProtocol,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)? = nil
    ) {
        self.categoryProductsScreenFactory = categoryProductsScreenFactory
        self.authService = authService
        self.makeCategoryProductsViewModel = makeCategoryProductsViewModel
        
        self.languageProvider = languageProvider
        self.localizer = localizer ?? DefaultCatalogLocalizer(languageProvider: languageProvider)
    }
    
    // MARK: - Screens
    
    func makeRoot(
        categoryId: String,
        title: String,
        onBack: @escaping () -> Void,
        onSelectProduct: @escaping (Product) -> Void
    ) -> AnyView {
        let userId = authService.currentUserId ?? ""
        let viewModel = makeCategoryProductsViewModel(userId, categoryId)
        
        return categoryProductsScreenFactory.makeCategoryProductsView(
            title: title,
            viewModel: viewModel,
            languageProvider: languageProvider,
            localizer: localizer,
            onSelectProduct: onSelectProduct,
            onBack: onBack
        )
    }
}
