//
//  ProductDetailsViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import Foundation
import Combine

/// ViewModel `ProductDetailsViewModel` для экрана карточки товара.
///
/// Основные задачи:
/// - Подписывается на `CatalogRepository` и публикует `product`;
/// - Отслеживает состояние в корзине и избранном
///   через `CartRepository` и `FavoritesRepository`;
/// - Подписывается на `ReviewsRepository` и публикует список отзывов;
/// - Вычисляет, может ли текущий пользователь оставить отзыв;
/// - Форматирует цену через `PriceFormattingProtocol`;
/// - Предоставляет паблишеры: `productPublisher`,
///   `isInCartPublisher`, `isFavoritePublisher`, `reviewsPublisher`.
///
/// Действия:
/// - Тоггл/добавление/удаление из избранного;
/// - Добавление в корзину, обновление количества,
///   удаление из корзины.
///
/// Реактивность:
/// - Обновления доставляются на главный поток;
/// - Состояния `isInCart`, `favoriteState` и `canWriteReviewState` дедуплицируются.
///
/// Примечание по локализации:
/// - Локализация (nameRu/nameEn, descriptionRu/descriptionEn) выполняется во View.
final class ProductDetailsViewModel: ObservableObject, ProductDetailsViewModelProtocol {
    
    private let productId: String
    private let currentUserId: String
    private let favoritesRepository: FavoritesRepository
    private let cartRepository: CartRepository
    private let catalogRepository: CatalogRepository
    private let reviewsRepository: ReviewsRepository
    private let priceFormatter: PriceFormattingProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var product: Product?
    @Published private var isInCart: Bool = false
    @Published private var favoriteState: Bool = false
    @Published private var reviewsState: [ProductReview] = []
    @Published private var canWriteReviewState: Bool = true
    
    // MARK: - Init
    
    init(
        productId: String,
        currentUserId: String,
        favoritesRepository: FavoritesRepository,
        cartRepository: CartRepository,
        catalogRepository: CatalogRepository,
        reviewsRepository: ReviewsRepository,
        priceFormatter: PriceFormattingProtocol
    ) {
        self.productId = productId
        self.currentUserId = currentUserId
        self.favoritesRepository = favoritesRepository
        self.cartRepository = cartRepository
        self.catalogRepository = catalogRepository
        self.reviewsRepository = reviewsRepository
        self.priceFormatter = priceFormatter
        
        bindProduct()
        bindCart()
        bindFavorites()
        bindReviews()
    }
    
    // MARK: - Outputs
    
    var productPublisher: AnyPublisher<Product?, Never> {
        $product.eraseToAnyPublisher()
    }
    
    var isInCartPublisher: AnyPublisher<Bool, Never> {
        $isInCart.eraseToAnyPublisher()
    }
    
    var isFavoritePublisher: AnyPublisher<Bool, Never> {
        $favoriteState.eraseToAnyPublisher()
    }
    
    var reviewsPublisher: AnyPublisher<[ProductReview], Never> {
        $reviewsState.eraseToAnyPublisher()
    }
    
    var canWriteReviewPublisher: AnyPublisher<Bool, Never> {
        $canWriteReviewState.eraseToAnyPublisher()
    }
    
    var reviews: [ProductReview] {
        reviewsState
    }
    
    var canWriteReview: Bool {
        canWriteReviewState
    }
    
    var priceText: String {
        guard let price = product?.price else { return "" }
        return formattedPrice(price)
    }
    
    var imageURL: String? {
        product?.imageURL
    }
    
    var isFavorite: Bool {
        favoriteState
    }
    
    var currentIsInCart: Bool {
        isInCart
    }
    
    // MARK: - Favorites actions
    
    func toggleFavorite() {
        Task {
            try? await favoritesRepository.toggle(productId: productId)
        }
    }
    
    func addToFavorites() {
        Task {
            try? await favoritesRepository.add(productId: productId)
        }
    }
    
    func removeFromFavorites() {
        Task {
            try? await favoritesRepository.remove(productId: productId)
        }
    }
    
    // MARK: - Cart actions
    
    func addToCart() {
        Task {
            try? await cartRepository.add(productId: productId, by: 1)
        }
    }
    
    func addToCart(quantity: Int) {
        guard quantity > 0 else { return }
        Task {
            try? await cartRepository.add(productId: productId, by: quantity)
        }
    }
    
    func updateQuantity(_ quantity: Int) {
        Task {
            try? await cartRepository.setQuantity(productId: productId, quantity: quantity)
        }
    }
    
    func removeFromCart() {
        Task {
            try? await cartRepository.remove(productId: productId)
        }
    }
    
    // MARK: - Bindings
    
    private func bindProduct() {
        catalogRepository.observeProduct(id: productId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                self?.product = product
            }
            .store(in: &cancellables)
    }
    
    private func bindCart() {
        cartRepository.observeItems()
            .map { [productId] items in
                items.contains(where: {
                    $0.productId == productId && $0.quantity > 0
                })
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$isInCart)
    }
    
    private func bindFavorites() {
        favoritesRepository.observeIds()
            .map { [productId] ids in ids.contains(productId) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$favoriteState)
    }
    
    private func bindReviews() {
        reviewsRepository.observeReviews()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reviews in
                guard let self else { return }
                self.reviewsState = reviews
                self.canWriteReviewState = !reviews.contains(where: {
                    $0.userId == self.currentUserId
                })
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Price
    
    private func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }
}
