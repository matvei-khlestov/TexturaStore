//
//  ProductDetailsViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import Foundation
import Combine

/// Протокол `ProductDetailsViewModelProtocol` определяет интерфейс ViewModel
/// для экрана карточки товара, предоставляя реактивные данные и методы
/// для управления состоянием товара в корзине, избранном и отзывами.
///
/// Локализация выполняется во View на основе `Product` и текущего языка.
protocol ProductDetailsViewModelProtocol: AnyObject {
    
    // MARK: - Outputs (для UI)
    
    /// Текущая модель товара (может быть `nil` во время загрузки).
    var product: Product? { get }
    
    /// Паблишер, отправляющий обновления данных товара.
    var productPublisher: AnyPublisher<Product?, Never> { get }
    
    /// Паблишер, уведомляющий об изменении состояния корзины.
    var isInCartPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Паблишер, уведомляющий об изменении состояния избранного.
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    
    /// Паблишер, отправляющий обновления списка отзывов товара.
    var reviewsPublisher: AnyPublisher<[ProductReview], Never> { get }
    
    /// Паблишер, уведомляющий, может ли текущий пользователь оставить отзыв.
    var canWriteReviewPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Текущий список отзывов товара.
    var reviews: [ProductReview] { get }
    
    /// Флаг, может ли текущий пользователь оставить отзыв.
    var canWriteReview: Bool { get }
    
    /// Отформатированная цена товара.
    var priceText: String { get }
    
    /// URL изображения товара.
    var imageURL: String? { get }
    
    /// Флаг, находится ли товар в избранном.
    var isFavorite: Bool { get }
    
    /// Флаг, находится ли товар в корзине.
    var currentIsInCart: Bool { get }
    
    // MARK: - Actions
    
    /// Переключает состояние избранного (добавить/удалить).
    func toggleFavorite()
    
    /// Добавляет товар в избранное.
    func addToFavorites()
    
    /// Удаляет товар из избранного.
    func removeFromFavorites()
    
    /// Добавляет товар в корзину (количество по умолчанию — 1).
    func addToCart()
    
    /// Добавляет товар в корзину в указанном количестве.
    func addToCart(quantity: Int)
    
    /// Обновляет количество товара в корзине.
    func updateQuantity(_ quantity: Int)
    
    /// Удаляет товар из корзины.
    func removeFromCart()
}
