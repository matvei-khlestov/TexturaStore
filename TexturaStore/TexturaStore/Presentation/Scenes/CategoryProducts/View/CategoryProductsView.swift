//
//  CategoryProductsView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI
import Combine
import Kingfisher

/// Экран товаров выбранной категории.
///
/// Отображает:
/// - сетку товаров с изображением, названием, брендом и ценой;
/// - поиск по товарам выбранной категории через `searchable`.
///
/// Взаимодействия:
/// - выбор товара (`onSelectProduct`);
/// - возврат назад (`onBack`);
/// - добавление/удаление товара в корзину и переключение избранного.
///
/// Реактивность:
/// - состояние товаров и списков ID корзины/избранного обновляется через паблишеры ViewModel;
/// - подписки выполнены через `.onReceive` без хранения `AnyCancellable` во View.
///
/// Особенности:
/// - View отвечает только за отображение и прокидывание действий наружу;
/// - бизнес-логика и работа с данными остаются внутри ViewModel и репозиториев.
struct CategoryProductsView: View {
    
    // MARK: - Callbacks (navigation-only)
    
    var onSelectProduct: ((Product) -> Void)?
    var onBack: (() -> Void)?
    
    // MARK: - Deps
    
    private let title: String
    private let viewModel: CategoryProductsViewModelProtocol
    
    private let localizer: CatalogLocalizing
    private let languagePublisher: AnyPublisher<AppLanguage, Never>
    
    // MARK: - State
    
    @State private var queryText: String = ""
    @State private var products: [Product] = []
    
    @State private var inCartIds: Set<String> = []
    @State private var favoriteIds: Set<String> = []
    
    @State private var language: AppLanguage
    
    // MARK: - Init
    
    init(
        title: String,
        viewModel: CategoryProductsViewModelProtocol,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)? = nil,
        onSelectProduct: ((Product) -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.title = title
        self.viewModel = viewModel
        self.onSelectProduct = onSelectProduct
        self.onBack = onBack

        self.languagePublisher = languageProvider.languagePublisher
        self.localizer = localizer ?? DefaultCatalogLocalizer(languageProvider: languageProvider)
        _language = State(initialValue: languageProvider.currentLanguage)
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProductsGridView(
                    products: products,
                    minColumnWidth: Metrics.Products.minColumnWidth,
                    rowSpacing: Metrics.Products.rowSpacing,
                    isInCart: { inCartIds.contains($0) },
                    isFavorite: { favoriteIds.contains($0) },
                    formattedPrice: viewModel.formattedPrice(_:),
                    productTitle: { localizer.productTitle($0) },
                    onSelect: { onSelectProduct?($0) },
                    onToggleCart: { product, toInCart in
                        if toInCart {
                            viewModel.addToCart(productId: product.id)
                        } else {
                            viewModel.removeFromCart(productId: product.id)
                        }
                    },
                    onToggleFavorite: { product in
                        viewModel.toggleFavorite(productId: product.id)
                    }
                )
                .padding(.horizontal, Metrics.Products.insetsHorizontal)
                .padding(.top, Metrics.Products.insetsTop)
                .padding(.bottom, Metrics.Products.insetsBottom)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .brandBackButton {
            onBack?()
        }
        .searchable(
            text: $queryText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: L10n.Catalog.Search.placeholder
        )
        .onAppear {
            queryText = viewModel.query
            viewModel.reload()
        }
        .onChange(of: queryText) { newValue in
            viewModel.query = newValue
        }
        .onReceive(viewModel.productsPublisher) {
            products = $0
        }
        .onReceive(viewModel.inCartIdsPublisher.removeDuplicates()) {
            inCartIds = $0
        }
        .onReceive(viewModel.favoriteIdsPublisher.removeDuplicates()) {
            favoriteIds = $0
        }
        .onReceive(languagePublisher.removeDuplicates()) {
            language = $0
        }
    }
}

// MARK: - Metrics

private extension CategoryProductsView {
    
    enum Metrics {
        enum Products {
            static let rowSpacing: CGFloat = 1
            static let insetsHorizontal: CGFloat = 8
            static let insetsTop: CGFloat = 8
            static let insetsBottom: CGFloat = 16
            static let minColumnWidth: CGFloat = 170
        }
    }
}
