//
//  CatalogView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import SwiftUI
import Combine
import Kingfisher

/// Экран каталога.
///
/// Отображает:
/// - список категорий в горизонтальном скролле;
/// - сетку товаров с изображением, названием, брендом и ценой;
/// - хедер секции товаров с кнопкой фильтров и бейджем активных фильтров;
/// - поиск по каталогу через `searchable`.
///
/// Взаимодействия:
/// - выбор категории (`onSelectCategory`);
/// - выбор товара (`onSelectProduct`);
/// - открытие фильтров (`onFilterTap`);
/// - добавление/удаление товара в корзину и переключение избранного.
///
/// Реактивность:
/// - состояние категорий/товаров/счётчика фильтров и списков ID корзины/избранного
///   обновляется через паблишеры ViewModel;
/// - подписки выполнены через `.onReceive` без хранения `AnyCancellable` во View.
///
/// Особенности:
/// - View отвечает только за отображение и прокидывание действий наружу;
/// - бизнес-логика и работа с данными остаются внутри ViewModel и репозиториев.
struct CatalogView: View {
    
    // MARK: - Callbacks
    
    var onSelectProduct: ((Product) -> Void)?
    var onFilterTap: ((FilterState) -> Void)?
    var onSelectCategory: ((Category) -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: CatalogViewModelProtocol
    
    private let localizer: CatalogLocalizing
    private let languagePublisher: AnyPublisher<AppLanguage, Never>
    
    // MARK: - State
    
    @State private var queryText: String = ""
    @State private var categories: [Category] = []
    @State private var products: [Product] = []
    @State private var activeFiltersCount: Int = 0
    
    @State private var inCartIds: Set<String> = []
    @State private var favoriteIds: Set<String> = []
    
    @State private var language: AppLanguage
    
    // MARK: - Init
    
    init(
        viewModel: CatalogViewModelProtocol,
        languageProvider: LanguageProviding = LocalizationLanguageProvider(),
        localizer: CatalogLocalizing? = nil,
        onSelectProduct: ((Product) -> Void)? = nil,
        onFilterTap: ((FilterState) -> Void)? = nil,
        onSelectCategory: ((Category) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onSelectProduct = onSelectProduct
        self.onFilterTap = onFilterTap
        self.onSelectCategory = onSelectCategory
        
        self.languagePublisher = languageProvider.languagePublisher
        self.localizer = localizer ?? DefaultCatalogLocalizer(languageProvider: languageProvider)
        _language = State(initialValue: languageProvider.currentLanguage)
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: Metrics.Categories.interGroupSpacing) {
                        ForEach(categories, id: \.id) { category in
                            CategoryItemView(
                                title: localizer.categoryTitle(category),
                                imageURL: category.imageURL,
                                count: viewModel.productCount(in: category.id)
                            )
                            .onTapGesture {
                                onSelectCategory?(category)
                            }
                        }
                    }
                    .padding(.top, Metrics.Categories.insetsTop)
                    .padding(.bottom, Metrics.Categories.insetsBottom)
                    .padding(.horizontal, Metrics.Categories.insetsHorizontal)
                }
                
                CatalogProductsHeaderView(
                    count: activeFiltersCount,
                    onFilterTap: {
                        onFilterTap?(viewModel.currentState)
                    }
                )
                .padding(.horizontal, Metrics.Header.insetsHorizontal)
                .padding(.top, Metrics.Header.insetsTop)
                .padding(.bottom, Metrics.Header.insetsBottom)
                
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
        .navigationTitle(L10n.Catalog.Navigation.title)
        .navigationBarTitleDisplayMode(.large)
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
        .onReceive(viewModel.categoriesPublisher) {
            categories = $0
        }
        .onReceive(viewModel.productsPublisher) {
            products = $0
        }
        .onReceive(viewModel.activeFiltersCountPublisher) {
            activeFiltersCount = $0
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

private extension CatalogView {
    
    enum Metrics {
        enum Categories {
            static let insetsHorizontal: CGFloat = 12
            static let insetsTop: CGFloat = 12
            static let insetsBottom: CGFloat = 8
            static let interGroupSpacing: CGFloat = 12
            
            static let itemWidth: CGFloat = 88
            static let imageSide: CGFloat = 64
        }
        
        enum Header {
            static let insetsHorizontal: CGFloat = 16
            static let insetsTop: CGFloat = 25
            static let insetsBottom: CGFloat = 15
        }
        
        enum Products {
            static let rowSpacing: CGFloat = 1
            static let insetsHorizontal: CGFloat = 8
            static let insetsTop: CGFloat = 0
            static let insetsBottom: CGFloat = 16
            static let minColumnWidth: CGFloat = 170
        }
    }
}
