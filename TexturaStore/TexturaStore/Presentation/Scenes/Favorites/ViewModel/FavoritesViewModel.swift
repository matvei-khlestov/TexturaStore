//
//  FavoritesViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import Foundation
import Combine
import UserNotifications

/// ViewModel `FavoritesViewModel` для экрана избранного.
///
/// Основные задачи:
/// - Наблюдение за списком избранных через `FavoritesRepository`;
/// - Отслеживание товаров, добавленных в корзину (`CartRepository`);
/// - Переключение состояния избранного и добавление/удаление товара из корзины;
/// - Удаление позиции свайпом и очистка списка избранного;
/// - Форматирование цен через `PriceFormattingProtocol`.
///
/// Локальные уведомления:
/// - Планирует напоминание о возвращении к избранному,
///   если список не пуст и товары не находятся в корзине;
/// - Отменяет уведомление, когда избранное пусто или часть товаров уже в корзине.
///
/// Реактивность:
/// - Все обновления доставляются на главный поток;
/// - Подписки управляются через Combine;
/// - Дедупликация и дебаунс снижают лишние обновления UI.

final class FavoritesViewModel: ObservableObject, FavoritesViewModelProtocol {
    
    // MARK: - Publishers
    
    var favoriteItemsPublisher: AnyPublisher<[FavoriteItem], Never> {
        $favoriteItems.eraseToAnyPublisher()
    }
    
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> {
        $inCartIds.eraseToAnyPublisher()
    }
    
    // MARK: - Deps
    
    private let favorites: FavoritesRepository
    private let cart: CartRepository
    private let priceFormatter: PriceFormattingProtocol
    private let notifications: LocalNotifyingProtocol
    
    // MARK: - State
    
    @Published private(set) var favoriteItems: [FavoriteItem] = []
    @Published private(set) var inCartIds: Set<String> = []
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Pending optimistic state (Cart)
    
    private var pendingCartAdds = Set<String>()
    private var pendingCartRemoves = Set<String>()
    
    // MARK: - Init
    
    init(
        favoritesRepository: FavoritesRepository,
        cartRepository: CartRepository,
        priceFormatter: PriceFormattingProtocol,
        notificationService: LocalNotifyingProtocol
    ) {
        self.favorites = favoritesRepository
        self.cart = cartRepository
        self.priceFormatter = priceFormatter
        self.notifications = notificationService
        bind()
    }
    
    private func bind() {
        favorites.observeItems()
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoriteItems)
        
        cart.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] serverIds in
                guard let self else { return }
                
                var merged = serverIds
                merged.formUnion(self.pendingCartAdds)
                merged.subtract(self.pendingCartRemoves)
                
                self.inCartIds = merged
            }
            .store(in: &bag)
        
        Publishers.CombineLatest($favoriteItems, $inCartIds)
            .removeDuplicates { lhs, rhs in
                lhs.0.map(\.productId) == rhs.0.map(\.productId) && lhs.1 == rhs.1
            }
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] favs, inCart in
                self?.updateFavoritesReminder(favs: favs, inCartIds: inCart)
            }
            .store(in: &bag)
    }
    
    // MARK: - Public API
    
    var count: Int { favoriteItems.count }
    
    func isInCart(_ id: String) -> Bool {
        inCartIds.contains(id)
    }
    
    func toggleFavorite(id: String) {
        Task {
            try? await favorites.toggle(productId: id)
        }
    }
    
    func toggleCart(for id: String) {
        let wasInCart = inCartIds.contains(id)
        
        if wasInCart {
            pendingCartAdds.remove(id)
            pendingCartRemoves.insert(id)
            inCartIds.remove(id)
        } else {
            pendingCartRemoves.remove(id)
            pendingCartAdds.insert(id)
            inCartIds.insert(id)
        }
        
        Task { [weak self] in
            do {
                if wasInCart {
                    try await self?.cart.remove(productId: id)
                } else {
                    try await self?.cart.add(productId: id, by: 1)
                }
                
                DispatchQueue.main.async {
                    self?.pendingCartAdds.remove(id)
                    self?.pendingCartRemoves.remove(id)
                }
            } catch {
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    if wasInCart {
                        self.pendingCartRemoves.remove(id)
                        self.inCartIds.insert(id)
                    } else {
                        self.pendingCartAdds.remove(id)
                        self.inCartIds.remove(id)
                    }
                }
            }
        }
    }
    
    func removeItem(with productId: String) {
        Task {
            try? await favorites.toggle(productId: productId)
        }
        
        if let idx = favoriteItems.firstIndex(where: { $0.productId == productId }) {
            favoriteItems.remove(at: idx)
        }
        
        pendingCartAdds.remove(productId)
        pendingCartRemoves.remove(productId)
        inCartIds.remove(productId)
    }
    
    func clearFavorites() {
        Task {
            try? await favorites.clear()
        }
        favoriteItems.removeAll()
    }
    
    func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }
}

// MARK: - Notifications

private extension FavoritesViewModel {
    
    func updateFavoritesReminder(favs: [FavoriteItem], inCartIds: Set<String>) {
        let hasFavorites = !favs.isEmpty
        let hasAnyInCart = favs.contains { inCartIds.contains($0.productId) }
        
        if hasFavorites && !hasAnyInCart {
            scheduleFavoritesReminder()
        } else {
            cancelFavoritesReminder()
        }
    }
    
    func scheduleFavoritesReminder() {
        _ = notifications.schedule(
            after: 60 * 60 * 24,
            id: NotificationTemplate.Favorites.id,
            title: NotificationTemplate.Favorites.title,
            body: NotificationTemplate.Favorites.body,
            categoryId: NotificationTemplate.Favorites.categoryId,
            userInfo: NotificationTemplate.Favorites.userInfo,
            unique: true
        )
    }
    
    func cancelFavoritesReminder() {
        notifications.cancel(ids: [NotificationTemplate.Favorites.id])
    }
}
