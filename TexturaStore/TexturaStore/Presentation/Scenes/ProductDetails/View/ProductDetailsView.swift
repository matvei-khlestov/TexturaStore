//
//  ProductDetailsView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI
import Combine
import Kingfisher

/// Экран карточки товара (SwiftUI).
///
/// Отвечает за:
/// - отображение изображения, названия, описания и цены товара;
/// - биндинг к `ProductDetailsViewModelProtocol` через Combine-паблишеры;
/// - локализацию полей товара (nameRu/nameEn, descriptionRu/descriptionEn) во View
///   через `LanguageProviding` и `CatalogLocalizing`;
/// - обработку действий: избранное / корзина с haptic-откликом.
///
/// SwiftGen не используется.
struct ProductDetailsView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: ProductDetailsViewModelProtocol
    private let languageProvider: LanguageProviding
    private let localizer: CatalogLocalizing
    
    // MARK: - Publishers
    
    private let languagePublisher: AnyPublisher<AppLanguage, Never>
    
    // MARK: - State
    
    @State private var product: Product?
    @State private var isInCart: Bool
    @State private var isFavorite: Bool
    @State private var priceText: String
    @State private var language: AppLanguage
    
    // MARK: - Init
    
    init(
        viewModel: ProductDetailsViewModelProtocol,
        languageProvider: LanguageProviding = LocalizationLanguageProvider(),
        localizer: CatalogLocalizing? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        
        self.languageProvider = languageProvider
        self.localizer = localizer ?? DefaultCatalogLocalizer(languageProvider: languageProvider)
        self.languagePublisher = languageProvider.languagePublisher
        
        _product = State(initialValue: viewModel.product)
        _isInCart = State(initialValue: viewModel.currentIsInCart)
        _isFavorite = State(initialValue: viewModel.isFavorite)
        _priceText = State(initialValue: viewModel.priceText)
        _language = State(initialValue: languageProvider.currentLanguage)
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.Spacing.verticalStack) {
                
                imageSection
                
                Text(productTitle)
                    .font(.system(size: Metrics.Fonts.titleSize, weight: .bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .multilineTextAlignment(.leading)
                
                Text(productDescription)
                    .font(.system(size: Metrics.Fonts.descriptionSize, weight: .regular))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .multilineTextAlignment(.leading)
                
                Text(priceText)
                    .font(.system(size: Metrics.Fonts.priceSize, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(1)
                
                controlsRow
            }
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.top, Metrics.Insets.verticalTop)
            .padding(.bottom, Metrics.Insets.verticalBottom)
        }
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.ProductDetails.Navigation.title)
        .brandBackButton {
            onBack?()
        }
        .onAppear {
            product = viewModel.product
            isInCart = viewModel.currentIsInCart
            isFavorite = viewModel.isFavorite
            priceText = viewModel.priceText
            language = languageProvider.currentLanguage
        }
        .onReceive(viewModel.productPublisher) {
            product = $0
            priceText = viewModel.priceText
        }
        .onReceive(viewModel.isInCartPublisher.removeDuplicates()) {
            isInCart = $0
        }
        .onReceive(viewModel.isFavoritePublisher.removeDuplicates()) {
            isFavorite = $0
        }
        .onReceive(languagePublisher.removeDuplicates()) {
            language = $0
        }
    }
}

// MARK: - UI

private extension ProductDetailsView {
    
    var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            ProductDetailsImage(urlString: product?.imageURL)
                .aspectRatio(Metrics.Layout.imageAspect, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.Corners.image))
            
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                viewModel.toggleFavorite()
            }) {
                ZStack {
                    Circle()
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .frame(width: Metrics.Sizes.likeButton, height: Metrics.Sizes.likeButton)
                    
                    Image(systemName: isFavorite ? Symbols.heartFilled : Symbols.heart)
                        .font(.system(size: Metrics.Sizes.favoriteSymbolPointSize, weight: .semibold))
                        .foregroundStyle(isFavorite ? Color(uiColor: .systemRed) : Color(uiColor: .label))
                }
            }
            .buttonStyle(.plain)
            .padding(Metrics.Spacing.likePadding)
            .accessibilityLabel(Text(isFavorite ? L10n.ProductDetails.Favorite.remove : L10n.ProductDetails.Favorite.add))
        }
    }
    
    var controlsRow: some View {
        HStack(spacing: 0) {
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if isInCart {
                    viewModel.removeFromCart()
                } else {
                    viewModel.addToCart()
                }
            }) {
                HStack(spacing: Metrics.Spacing.cartInner) {
                    Image(systemName: isInCart ? Symbols.cartFilled : Symbols.cart)
                        .font(.system(size: Metrics.Sizes.cartSymbolPointSize, weight: .semibold))
                    
                    Text(isInCart ? L10n.ProductDetails.Cart.in : L10n.ProductDetails.Cart.add)
                        .font(.system(size: Metrics.Fonts.cartButtonSize, weight: .semibold))
                }
                .foregroundStyle(isInCart ? Color(uiColor: .brand) : .white)
                .padding(.horizontal, Metrics.Insets.cartButtonH)
                .padding(.vertical, Metrics.Insets.cartButtonV)
                .background(
                    Capsule().fill(
                        Color(uiColor: .brand).opacity(isInCart ? 0.18 : 1.0)
                    )
                )
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Localization (View owns it)

private extension ProductDetailsView {
    
    var productTitle: String {
        guard let product else { return L10n.ProductDetails.loading }
        return localizer.productTitle(product)
    }
    
    var productDescription: String {
        guard let product else { return "" }
        switch language {
        case .ru:
            return product.descriptionRu
        case .en:
            return product.descriptionEn
        }
    }
}

// MARK: - Image

private struct ProductDetailsImage: View {
    
    let urlString: String?
    
    var body: some View {
        let url = URL(string: urlString ?? "")
        
        KFImage(url)
            .placeholder { Color(uiColor: .secondarySystemBackground) }
            .cacheOriginalImage()
            .fade(duration: 0.15)
            .resizable()
            .scaledToFill()
            .clipped()
    }
}

// MARK: - Metrics

private extension ProductDetailsView {
    
    enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 16
            static let verticalBottom: CGFloat = 16
            
            static let cartButtonH: CGFloat = 14
            static let cartButtonV: CGFloat = 10
        }
        
        enum Spacing {
            static let verticalStack: CGFloat = 16
            static let likePadding: CGFloat = 12
            static let cartInner: CGFloat = 8
        }
        
        enum Fonts {
            static let titleSize: CGFloat = 20
            static let descriptionSize: CGFloat = 15
            static let priceSize: CGFloat = 18
            static let cartButtonSize: CGFloat = 14
        }
        
        enum Sizes {
            static let likeButton: CGFloat = 36
            static let favoriteSymbolPointSize: CGFloat = 20
            static let cartSymbolPointSize: CGFloat = 16
            static let backPointSize: CGFloat = 16
        }
        
        enum Corners {
            static let image: CGFloat = 12
        }
        
        enum Layout {
            static let imageAspect: CGFloat = 3.0 / 3.0
        }
    }
    
    enum Symbols {
        static let heartFilled = "heart.fill"
        static let heart = "heart"
        static let cartFilled = "cart.fill"
        static let cart = "cart"
        static let back = "chevron.left"
    }
}
