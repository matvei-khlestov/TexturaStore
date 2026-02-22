//
//  CatalogViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import Foundation
import Combine

/// ViewModel `CatalogViewModel` для экрана каталога.
///
/// Основные задачи:
/// - Загружает категории и товары из `CatalogRepository`;
/// - Ведёт поисковый запрос `query` с дебаунсом;
/// - Применяет фильтры (категории, бренды, цены);
/// - Обновляет счётчики товаров по категориям;
/// - Форматирует цены через `PriceFormattingProtocol`;
/// - Управляет добавлением/удалением из корзины и избранного.
///
/// Реактивность:
/// - Паблишеры: `categoriesPublisher`, `productsPublisher`,
///   `activeFiltersCountPublisher`, `inCartIdsPublisher`,
///   `favoriteIdsPublisher`;
/// - Все обновления доставляются на главный поток;
/// - Реал-тайм синхронизация каталога при `reload()`.
///
/// Особенности:
/// - Дедупликация и дебаунс поиска снижают лишние перерисовки;
/// - Фильтры хранятся в `FilterState` и пересчитываются
///   через `applyFilters(_:)`;
/// - Подписки хранятся в `bag`, наблюдение товаров
///   отменяется и пересоздаётся при каждом запросе.
final class CatalogViewModel: ObservableObject, CatalogViewModelProtocol {
    
    // MARK: - Inputs
    
    @Published var query: String = ""
    
    // MARK: - Outputs
    
    @Published private(set) var categories: [Category] = []
    @Published private(set) var products: [Product] = []
    @Published private(set) var activeFiltersCount: Int = 0
    
    var categoriesPublisher: AnyPublisher<[Category], Never> {
        $categories.eraseToAnyPublisher()
    }
    
    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }
    
    var activeFiltersCountPublisher: AnyPublisher<Int, Never> {
        $activeFiltersCount.eraseToAnyPublisher()
    }
    
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> {
        $inCartIds.eraseToAnyPublisher()
    }
    
    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> {
        $favoriteIds.eraseToAnyPublisher()
    }
    
    // MARK: - Deps
    
    private let repo: CatalogRepository
    private let cart: CartRepository
    private let favorites: FavoritesRepository
    private let priceFormatter: PriceFormattingProtocol
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var realtimeStarted = false
    private var countsByCategory: [String: Int] = [:]
    
    private var filterState = FilterState()
    
    var currentState: FilterState {
        filterState
    }
    
    private var productsCancellable: AnyCancellable?
    @Published private var inCartIds = Set<String>()
    @Published private var favoriteIds = Set<String>()
    
    // MARK: - Pending optimistic state (Favorites)
    
    private var pendingFavoriteAdds = Set<String>()
    private var pendingFavoriteRemoves = Set<String>()
    
    // MARK: - Init
    
    init(
        repository: CatalogRepository,
        cartRepository: CartRepository,
        favoritesRepository: FavoritesRepository,
        priceFormatter: PriceFormattingProtocol
    ) {
        self.repo = repository
        self.cart = cartRepository
        self.favorites = favoritesRepository
        self.priceFormatter = priceFormatter
        bind()
        refreshProducts()
    }
    
    // MARK: - Public
    
    func reload() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await repo.refreshAll()
            } catch {
                print("❌ CatalogViewModel.refreshAll error:", error)
            }
        }
        if !realtimeStarted {
            repo.startRealtimeSync()
            realtimeStarted = true
        }
    }
    
    func applyFilters(_ state: FilterState) {
        filterState = state
        recalcActiveFiltersCount()
        refreshProducts()
    }
    
    func productCount(in categoryId: String) -> Int {
        countsByCategory[categoryId] ?? 0
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

// MARK: - Bindings + helpers

private extension CatalogViewModel {
    func bind() {
        repo.observeCategories()
            .receive(on: DispatchQueue.main)
            .assign(to: &$categories)
        
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
        
        let cats = filterState.selectedCategoryIds.isEmpty ? nil : Set(filterState.selectedCategoryIds)
        let brands = filterState.selectedBrandIds.isEmpty ? nil : Set(filterState.selectedBrandIds)
        let colors = filterState.selectedColorIds.isEmpty ? nil : Set(filterState.selectedColorIds)
        
        productsCancellable?.cancel()
        productsCancellable = repo.observeProducts(
            query: q,
            categoryIds: cats,
            brandIds: brands,
            colorIds: colors,
            minPrice: filterState.minPrice,
            maxPrice: filterState.maxPrice
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] items in
            self?.products = items
            self?.rebuildCounts(from: items)
        }
    }
    
    func rebuildCounts(from items: [Product]) {
        var dict: [String: Int] = [:]
        for p in items { dict[p.categoryId, default: 0] += 1 }
        countsByCategory = dict
    }
    
    func recalcActiveFiltersCount() {
        activeFiltersCount =
        filterState.selectedCategoryIds.count +
        filterState.selectedBrandIds.count +
        filterState.selectedColorIds.count +
        (filterState.minPrice == nil ? 0 : 1) +
        (filterState.maxPrice == nil ? 0 : 1)
    }
}
