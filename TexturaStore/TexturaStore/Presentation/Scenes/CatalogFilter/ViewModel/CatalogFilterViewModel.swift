//
//  CatalogFilterViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import Foundation
import Combine

final class CatalogFilterViewModel: ObservableObject, CatalogFilterViewModelProtocol {
    
    // MARK: - Deps
    
    private let repo: CatalogRepository
    
    // MARK: - Storage (списки в UI)
    
    @Published private var categoriesStorage: [Category] = []
    @Published private var brandsStorage: [Brand] = []
    @Published private var colorsStorage: [ProductColor] = []
    
    // MARK: - Выбор пользователя
    
    private var selectedCategoryIds = Set<String>()
    private var selectedBrandIds = Set<String>()
    private var selectedColorIds = Set<String>()
    
    private var minPrice: Decimal?
    private var maxPrice: Decimal?
    
    // MARK: - Publishers (state + count)
    
    private let _state = CurrentValueSubject<FilterState, Never>(.init())
    
    var statePublisher: AnyPublisher<FilterState, Never> {
        _state.eraseToAnyPublisher()
    }
    
    private let _foundCount = CurrentValueSubject<Int, Never>(0)
    
    var foundCountPublisher: AnyPublisher<Int, Never> {
        _foundCount.eraseToAnyPublisher()
    }
    
    var currentFoundCount: Int {
        _foundCount.value
    }
    
    // MARK: - Other
    
    private var bag = Set<AnyCancellable>()
    private var productsCancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(repository: CatalogRepository) {
        self.repo = repository
        
        repo.observeCategories()
            .map { items in
                items.sorted(by: { $0.id < $1.id })
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$categoriesStorage)
        
        repo.observeBrands()
            .map { items in
                items.sorted(by: { $0.id < $1.id })
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$brandsStorage)
        
        repo.observeProductColors()
            .map { items in
                items
                    .filter(\.isActive)
                    .sorted(by: { $0.id < $1.id })
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$colorsStorage)
        
        emitStateAndRefetch()
    }
    
    // MARK: - Outputs
    
    var categories: AnyPublisher<[Category], Never> {
        $categoriesStorage.removeDuplicates().eraseToAnyPublisher()
    }
    
    var brands: AnyPublisher<[Brand], Never> {
        $brandsStorage.removeDuplicates().eraseToAnyPublisher()
    }
    
    var colors: AnyPublisher<[ProductColor], Never> {
        $colorsStorage.removeDuplicates().eraseToAnyPublisher()
    }
    
    var currentState: FilterState {
        _state.value
    }
    
    // MARK: - Actions
    
    func toggleCategory(id: String) {
        if selectedCategoryIds.contains(id) {
            selectedCategoryIds.remove(id)
        } else {
            selectedCategoryIds.insert(id)
        }
        emitStateAndRefetch()
    }
    
    func toggleBrand(id: String) {
        if selectedBrandIds.contains(id) {
            selectedBrandIds.remove(id)
        } else {
            selectedBrandIds.insert(id)
        }
        emitStateAndRefetch()
    }
    
    func toggleColor(id: String) {
        if selectedColorIds.contains(id) {
            selectedColorIds.remove(id)
        } else {
            selectedColorIds.insert(id)
        }
        emitStateAndRefetch()
    }
    
    func setMinPrice(_ text: String?) {
        minPrice = text.flatMap {
            Decimal(string: $0.replacingOccurrences(of: ",", with: "."))
        }
        emitStateAndRefetch()
    }
    
    func setMaxPrice(_ text: String?) {
        maxPrice = text.flatMap {
            Decimal(string: $0.replacingOccurrences(of: ",", with: "."))
        }
        emitStateAndRefetch()
    }
    
    func reset() {
        selectedCategoryIds.removeAll()
        selectedBrandIds.removeAll()
        selectedColorIds.removeAll()
        minPrice = nil
        maxPrice = nil
        emitStateAndRefetch()
    }
    
    // MARK: - Helpers
    
    private func emitStateAndRefetch() {
        let state = FilterState(
            selectedCategoryIds: selectedCategoryIds,
            selectedBrandIds: selectedBrandIds,
            selectedColorIds: selectedColorIds,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
        _state.send(state)
        
        let isEmptyFilter =
        selectedCategoryIds.isEmpty
        && selectedBrandIds.isEmpty
        && selectedColorIds.isEmpty
        && minPrice == nil
        && maxPrice == nil
        
        if isEmptyFilter {
            productsCancellable?.cancel()
            _foundCount.send(0)
            return
        }
        
        productsCancellable?.cancel()
        productsCancellable = repo.observeProducts(
            query: nil,
            categoryIds: selectedCategoryIds.isEmpty ? nil : selectedCategoryIds,
            brandIds: selectedBrandIds.isEmpty ? nil : selectedBrandIds,
            colorIds: selectedColorIds.isEmpty ? nil : selectedColorIds,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
        .map(\.count)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] count in
            self?._foundCount.send(count)
        }
    }
}
