//
//  CatalogStoreProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import Foundation
import Combine

/// Протокол хранилища каталога (`CatalogStoreProtocol`) в слое данных.
///
/// Назначение:
/// - определяет контракт для получения и наблюдения за данными каталога из Supabase;
/// - инкапсулирует работу с удалённым источником (PostgreSQL + Realtime);
/// - используется репозиториями каталога для синхронизации данных.
///
/// Поддерживаемые сущности:
/// - товары (`ProductDTO`);
/// - категории (`CategoryDTO`);
/// - бренды (`BrandDTO`);
/// - цвета товаров (`ProductColorDTO`).
///
/// Архитектурная роль:
/// - слой Data (Store);
/// - возвращает DTO-модели, изолированные от Domain и UI;
/// - не содержит бизнес-логики.
///
/// Особенности:
/// - `fetch*` методы выполняют одноразовую загрузку данных;
/// - `listen*` методы предоставляют Combine-паблишеры для реактивного обновления данных;
/// - предполагается использование Supabase Realtime Channels для подписок.
///
/// Использование:
/// - `DefaultCatalogRepository`
/// - `CoreDataCatalogStore` (как локальный кеш)
protocol CatalogStoreProtocol: AnyObject {
    
    // MARK: - Products
    
    /// Загружает список всех товаров.
    /// - Returns: Массив `ProductDTO` с основной информацией о товарах.
    func fetchProducts() async throws -> [ProductDTO]
    
    /// Реактивно слушает изменения в списке товаров.
    /// - Returns: Паблишер с актуальными `ProductDTO`.
    func listenProducts() -> AnyPublisher<[ProductDTO], Never>
    
    
    // MARK: - Categories
    
    /// Загружает список категорий каталога.
    /// - Returns: Массив `CategoryDTO` с категориями.
    func fetchCategories() async throws -> [CategoryDTO]
    
    /// Реактивно слушает изменения в списке категорий.
    /// - Returns: Паблишер с актуальными `CategoryDTO`.
    func listenCategories() -> AnyPublisher<[CategoryDTO], Never>
    
    
    // MARK: - Brands
    
    /// Загружает список брендов.
    /// - Returns: Массив `BrandDTO` с доступными брендами.
    func fetchBrands() async throws -> [BrandDTO]
    
    /// Реактивно слушает изменения в списке брендов.
    /// - Returns: Паблишер с актуальными `BrandDTO`.
    func listenBrands() -> AnyPublisher<[BrandDTO], Never>
    
    
    // MARK: - Product Colors
    
    /// Загружает список цветов товаров.
    /// - Returns: Массив `ProductColorDTO` с доступными цветами.
    func fetchProductColors() async throws -> [ProductColorDTO]
    
    /// Реактивно слушает изменения в списке цветов товаров.
    /// - Returns: Паблишер с актуальными `ProductColorDTO`.
    func listenProductColors() -> AnyPublisher<[ProductColorDTO], Never>
}
