//
//  CatalogFilterViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import Foundation
import Combine

/// Протокол `CatalogFilterViewModelProtocol` определяет интерфейс ViewModel
/// для экрана фильтрации каталога товаров.
///
/// Отвечает за формирование и публикацию состояния фильтров (`FilterState`),
/// а также за реактивное предоставление данных категорий, брендов, цветов и количества найденных товаров.
///
/// Основные задачи:
/// - Управление выбором категорий, брендов и цветов;
/// - Установка и сброс диапазона цен;
/// - Расчёт количества найденных товаров при изменении фильтров;
/// - Предоставление реактивных потоков (`Combine`) для обновления UI.
///
/// Используется во `CatalogFilterViewController`.
protocol CatalogFilterViewModelProtocol {
    
    // MARK: - Actions
    
    /// Переключает выбор категории по её идентификатору.
    func toggleCategory(id: String)
    
    /// Переключает выбор бренда по его идентификатору.
    func toggleBrand(id: String)
    
    /// Переключает выбор цвета по его идентификатору.
    func toggleColor(id: String)
    
    /// Устанавливает минимальную цену фильтра.
    func setMinPrice(_ text: String?)
    
    /// Устанавливает максимальную цену фильтра.
    func setMaxPrice(_ text: String?)
    
    /// Сбрасывает все фильтры (категории, бренды, цвета, цены).
    func reset()
    
    // MARK: - Publishers
    
    /// Паблишер категорий, отсортированных по алфавиту.
    var categories: AnyPublisher<[Category], Never> { get }
    
    /// Паблишер брендов, отсортированных по алфавиту.
    var brands: AnyPublisher<[Brand], Never> { get }
    
    /// Паблишер цветов, отсортированных по алфавиту (с учётом текущего языка, если доступно).
    var colors: AnyPublisher<[ProductColor], Never> { get }
    
    /// Паблишер текущего состояния фильтров.
    var statePublisher: AnyPublisher<FilterState, Never> { get }
    
    /// Паблишер количества найденных товаров.
    var foundCountPublisher: AnyPublisher<Int, Never> { get }
    
    // MARK: - Current values
    
    /// Текущее состояние фильтров.
    var currentState: FilterState { get }
    
    /// Текущее количество найденных товаров.
    var currentFoundCount: Int { get }
}
