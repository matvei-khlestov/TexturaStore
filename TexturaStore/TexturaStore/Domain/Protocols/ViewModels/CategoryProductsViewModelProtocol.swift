//
//  CategoryProductsViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import Combine

/// Протокол `CategoryProductsViewModelProtocol` определяет интерфейс ViewModel
/// для экрана товаров выбранной категории, предоставляя реактивные данные
/// и действия для управления списком товаров, корзиной и избранным.
///
/// Описывает входные параметры (`Inputs`), выходные данные (`Outputs`)
/// и интенты (`Actions`), используемые в UI слоях (SwiftUI / UIKit).
///
/// Основные задачи:
/// - загрузка и наблюдение за товарами категории (репозиторий/стор);
/// - поиск по товарам через `query` и обновление списка;
/// - управление состоянием корзины (add/remove) и избранного (add/remove/toggle);
/// - форматирование цен через `formattedPrice(_:)`.
///
/// Реактивность:
/// - обновления списка товаров и состояний корзины/избранного передаются через Combine-паблишеры;
/// - изменения должны доставляться на главный поток (MainActor / receive(on: RunLoop.main)).
protocol CategoryProductsViewModelProtocol: AnyObject {
    
    // MARK: - Search
    
    /// Текущий поисковый запрос.
    var query: String { get set }
    
    /// Перезагружает данные экрана (обновляет товары и состояния).
    func reload()
    
    // MARK: - Products
    
    /// Текущий массив товаров (с учётом выбранной категории и/или поиска).
    var products: [Product] { get }
    
    /// Паблишер товаров (реактивные обновления списка).
    var productsPublisher: AnyPublisher<[Product], Never> { get }
    
    // MARK: - Cart
    
    /// Паблишер ID товаров, находящихся в корзине.
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    /// Добавляет товар в корзину.
    func addToCart(productId: String)
    
    /// Удаляет товар из корзины.
    func removeFromCart(productId: String)
    
    // MARK: - Favorites
    
    /// Паблишер ID товаров, находящихся в избранном.
    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    /// Добавляет товар в избранное.
    func addToFavorites(productId: String)
    
    /// Удаляет товар из избранного.
    func removeFromFavorites(productId: String)
    
    /// Переключает состояние избранного для товара.
    func toggleFavorite(productId: String)
    
    // MARK: - Helpers
    
    /// Форматирует цену в строку.
    func formattedPrice(_ price: Double) -> String
}
