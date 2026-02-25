//
//  CatalogFilterView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI
import Combine

/// SwiftUI-экран фильтра каталога.
///
/// Секции:
/// - Категории
/// - Бренды
/// - Цвета
/// - Цена
///
/// Локализация:
/// - Названия цветов берутся из `ProductColor.nameRu/nameEn` по текущему языку (как в ProductDetailsView).
@MainActor
struct CatalogFilterView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onApply: ((FilterState) -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: any CatalogFilterViewModelProtocol
    private let initialState: FilterState
    
    private let languageProvider: any LanguageProviding
    private let localizer: any CatalogLocalizing
    
    // MARK: - Publishers
    
    private let languagePublisher: AnyPublisher<AppLanguage, Never>
    
    // MARK: - State
    
    @State private var categories: [Category] = []
    @State private var brands: [Brand] = []
    @State private var colors: [ProductColor] = []
    
    @State private var currentState: FilterState
    @State private var foundCount: Int
    
    @State private var minPriceText: String
    @State private var maxPriceText: String
    
    @State private var didApplyInitialState: Bool = false
    @State private var language: AppLanguage
    
    // MARK: - Init
    
    init(
        viewModel: any CatalogFilterViewModelProtocol,
        initialState: FilterState,
        languageProvider: any LanguageProviding,
        localizer: (any CatalogLocalizing)? = nil,
        onBack: (() -> Void)? = nil,
        onApply: ((FilterState) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.initialState = initialState
        self.onBack = onBack
        self.onApply = onApply
        
        self.languageProvider = languageProvider
        self.localizer = localizer ?? DefaultCatalogLocalizer(languageProvider: languageProvider)
        self.languagePublisher = languageProvider.languagePublisher
        
        _currentState = State(initialValue: initialState)
        _foundCount = State(initialValue: viewModel.currentFoundCount)
        _language = State(initialValue: languageProvider.currentLanguage)
        
        _minPriceText = State(initialValue: Self.decimalString(initialState.minPrice))
        _maxPriceText = State(initialValue: Self.decimalString(initialState.maxPrice))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: Metrics.Spacing.sectionSpacing) {
                
                // Categories
                FilterSectionHeaderView(title: L10n.Catalog.Filter.Header.categories)
                CapsuleFlowGrid(items: categories, id: \.id) { category in
                    FilterCapsuleView(
                        title: localizer.categoryTitle(category),
                        isSelected: currentState.selectedCategoryIds.contains(category.id),
                        leading: {
                            FilterCapsuleImageView(imageURL: category.imageURL)
                        },
                        onTap: { viewModel.toggleCategory(id: category.id) }
                    )
                    .accessibilityLabel(Text(localizer.categoryTitle(category)))
                }
                
                // Brands
                FilterSectionHeaderView(title: L10n.Catalog.Filter.Header.brands)
                CapsuleFlowGrid(items: brands, id: \.id) { brand in
                    FilterCapsuleView(
                        title: brand.name,
                        isSelected: currentState.selectedBrandIds.contains(brand.id),
                        leading: {
                            FilterCapsuleImageView(imageURL: brand.imageURL)
                        },
                        onTap: { viewModel.toggleBrand(id: brand.id) }
                    )
                    .accessibilityLabel(Text(brand.name))
                }
                
                // Colors
                FilterSectionHeaderView(title: L10n.Catalog.Filter.Header.colors)
                CapsuleFlowGrid(items: colors, id: \.id) { color in
                    FilterCapsuleView(
                        title: localizer.colorTitle(color),
                        isSelected: currentState.selectedColorIds.contains(color.id),
                        leading: {
                            ColorDotView(hex: color.hex)
                        },
                        onTap: { viewModel.toggleColor(id: color.id) }
                    )
                    .accessibilityLabel(Text(localizer.colorTitle(color)))
                }
                
                // Price
                FilterSectionHeaderView(title: L10n.Catalog.Filter.Header.price)
                PriceRangeFieldsView(
                    minPlaceholder: L10n.Catalog.Filter.Price.min,
                    maxPlaceholder: L10n.Catalog.Filter.Price.max,
                    minText: $minPriceText,
                    maxText: $maxPriceText
                )
            }
            .padding(.top, Metrics.Insets.top)
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.bottom, Metrics.Insets.bottom)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.Catalog.Filter.Navigation.title)
        .brandBackButton {
            onBack?()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: resetTapped) {
                    Text(L10n.Catalog.Filter.reset)
                        .font(.system(size: Metrics.Fonts.resetSize, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .brand))
                }
                .buttonStyle(.plain)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FilterBottomBarView(
                count: foundCount,
                hasActiveFilters: !currentState.isEmpty,
                onApply: { onApply?(currentState) }
            )
            .background(
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .onAppear {
            TabBarVisibilityController.setHidden(true)
            applyInitialStateIfNeeded()
        }
        .onDisappear {
            TabBarVisibilityController.setHidden(false)
        }
        .onReceive(viewModel.categories) { categories = $0 }
        .onReceive(viewModel.brands) { brands = $0 }
        .onReceive(viewModel.colors) { colors = $0 }
        .onReceive(viewModel.statePublisher) { currentState = $0 }
        .onReceive(viewModel.foundCountPublisher) { foundCount = $0 }
        .onReceive(languagePublisher.removeDuplicates()) { language = $0 }
        .onChange(of: minPriceText) { viewModel.setMinPrice($0.nilIfEmpty) }
        .onChange(of: maxPriceText) { viewModel.setMaxPrice($0.nilIfEmpty) }
    }
}

// MARK: - Actions

private extension CatalogFilterView {
    
    func applyInitialStateIfNeeded() {
        guard !didApplyInitialState else { return }
        didApplyInitialState = true
        
        initialState.selectedCategoryIds.forEach { viewModel.toggleCategory(id: $0) }
        initialState.selectedBrandIds.forEach { viewModel.toggleBrand(id: $0) }
        initialState.selectedColorIds.forEach { viewModel.toggleColor(id: $0) }
        
        if let min = initialState.minPrice {
            minPriceText = Self.decimalString(min)
            viewModel.setMinPrice(minPriceText.nilIfEmpty)
        }
        
        if let max = initialState.maxPrice {
            maxPriceText = Self.decimalString(max)
            viewModel.setMaxPrice(maxPriceText.nilIfEmpty)
        }
    }
    
    func resetTapped() {
        minPriceText = ""
        maxPriceText = ""
        viewModel.reset()
    }
}

// MARK: - Helpers

private extension CatalogFilterView {
    
    static func decimalString(_ value: Decimal?) -> String {
        guard let value else { return "" }
        return NSDecimalNumber(decimal: value).stringValue
    }
}

// MARK: - Metrics

private enum Metrics {
    enum Insets {
        static let horizontal: CGFloat = 16
        static let top: CGFloat = 12
        static let bottom: CGFloat = 12
    }
    
    enum Spacing {
        static let sectionSpacing: CGFloat = 18
    }
    
    enum Fonts {
        static let resetSize: CGFloat = 15
    }
}

private extension String {
    var nilIfEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
