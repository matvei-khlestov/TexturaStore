//
//  CategoryProductsViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import Foundation
import Combine

/// ViewModel `CategoryProductsViewModel` для экрана товаров выбранной категории.
///
/// Основные задачи:
/// - загружает и наблюдает за товарами категории из `CatalogRepository`;
/// - ведёт поисковый запрос `query` с дебаунсом;
/// - управляет состоянием корзины и избранного;
/// - форматирует цены через `PriceFormattingProtocol`.
///
/// Реактивность:
/// - паблишеры: `productsPublisher`, `inCartIdsPublisher`, `favoriteIdsPublisher`;
/// - все обновления доставляются на главный поток;
/// - поддерживается оптимистичное обновление избранного.
///
/// Особенности:
/// - поиск с debounce снижает количество перезапросов;
/// - optimistic UI для favorites с rollback при ошибке;
/// - подписки управляются через `bag`.
final class CategoryProductsViewModel: ObservableObject, CategoryProductsViewModelProtocol {
    
    // MARK: - Inputs
    
    @Published var query: String = ""
    
    // MARK: - Outputs
    
    @Published private(set) var products: [Product] = []
    
    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }
    
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> {
        $inCartIds.eraseToAnyPublisher()
    }
    
    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> {
        $favoriteIds.eraseToAnyPublisher()
    }
    
    // MARK: - Deps
    
    private let categoryId: String
    private let repo: CatalogRepository
    private let cart: CartRepository
    private let favorites: FavoritesRepository
    private let priceFormatter: PriceFormattingProtocol
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var productsCancellable: AnyCancellable?
    
    @Published private var inCartIds = Set<String>()
    @Published private var favoriteIds = Set<String>()
    
    // MARK: - Pending optimistic state (Favorites)
    
    private var pendingFavoriteAdds = Set<String>()
    private var pendingFavoriteRemoves = Set<String>()
    
    // MARK: - Init
    
    init(
        categoryId: String,
        repository: CatalogRepository,
        cartRepository: CartRepository,
        favoritesRepository: FavoritesRepository,
        priceFormatter: PriceFormattingProtocol
    ) {
        self.categoryId = categoryId
        self.repo = repository
        self.cart = cartRepository
        self.favorites = favoritesRepository
        self.priceFormatter = priceFormatter
        
        bind()
        refreshProducts()
    }
    
    // MARK: - Public API
    
    func reload() {
        refreshProducts()
    }
    
    func addToCart(productId: String) {
        inCartIds.insert(productId)
        
        Task { [weak self] in
            do {
                try await self?.cart.add(productId: productId, by: 1)
            } catch {
                DispatchQueue.main.async {
                    self?.inCartIds.remove(productId)
                }
            }
        }
    }
    
    func removeFromCart(productId: String) {
        inCartIds.remove(productId)
        
        Task { [weak self] in
            do {
                try await self?.cart.remove(productId: productId)
            } catch {
                DispatchQueue.main.async {
                    self?.inCartIds.insert(productId)
                }
            }
        }
    }
    
    func addToFavorites(productId: String) {
        Task {
            try? await favorites.add(productId: productId)
        }
    }
    
    func removeFromFavorites(productId: String) {
        Task {
            try? await favorites.remove(productId: productId)
        }
    }
    
    func toggleFavorite(productId: String) {
        let wasFavorite = favoriteIds.contains(productId)
        
        if wasFavorite {
            pendingFavoriteAdds.remove(productId)
            pendingFavoriteRemoves.insert(productId)
            favoriteIds.remove(productId)
        } else {
            pendingFavoriteRemoves.remove(productId)
            pendingFavoriteAdds.insert(productId)
            favoriteIds.insert(productId)
        }
        
        Task { [weak self] in
            do {
                if wasFavorite {
                    try await self?.favorites.remove(productId: productId)
                } else {
                    try await self?.favorites.add(productId: productId)
                }
                
                DispatchQueue.main.async {
                    self?.pendingFavoriteAdds.remove(productId)
                    self?.pendingFavoriteRemoves.remove(productId)
                }
            } catch {
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    // rollback optimistic
                    if wasFavorite {
                        self.pendingFavoriteRemoves.remove(productId)
                        self.favoriteIds.insert(productId)
                    } else {
                        self.pendingFavoriteAdds.remove(productId)
                        self.favoriteIds.remove(productId)
                    }
                }
            }
        }
    }
    
    func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }
}

// MARK: - Bindings & Helpers

private extension CategoryProductsViewModel {
    
    func bind() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshProducts()
            }
            .store(in: &bag)
        
        cart.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$inCartIds)
        
        favorites.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] serverIds in
                guard let self else { return }
                
                var merged = serverIds
                merged.formUnion(self.pendingFavoriteAdds)
                merged.subtract(self.pendingFavoriteRemoves)
                
                self.favoriteIds = merged
            }
            .store(in: &bag)
    }
    
    func refreshProducts() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let q: String? = trimmed.isEmpty ? nil : trimmed
        
        productsCancellable?.cancel()
        productsCancellable = repo.observeProducts(
            query: q,
            categoryIds: [categoryId],
            brandIds: nil,
            colorIds: nil,
            minPrice: nil,
            maxPrice: nil
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] items in
            self?.products = items
        }
    }
}
