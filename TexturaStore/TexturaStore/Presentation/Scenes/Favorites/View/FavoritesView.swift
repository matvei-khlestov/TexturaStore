//
//  FavoritesView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI
import Combine

struct FavoritesView: View {
    
    // MARK: - Callbacks
    
    var onSelectProduct: ((String) -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: FavoritesViewModelProtocol
    
    // MARK: - State
    
    @State private var items: [FavoriteItem] = []
    @State private var inCartIds: Set<String> = []
    @State private var bag = Set<AnyCancellable>()
    
    @State private var showClearConfirm = false
    
    // MARK: - Init
    
    init(
        viewModel: FavoritesViewModelProtocol,
        onSelectProduct: ((String) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onSelectProduct = onSelectProduct
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if items.isEmpty {
                EmptyStateView(
                    text: L10n.Favorites.emptyState,
                    horizontalPadding: 24
                )
            } else {
                ProductsListView(
                    items: items,
                    id: \.productId,
                    deleteTitle: L10n.Favorites.Swipe.delete,
                    onSelect: { item in
                        onSelectProduct?(item.productId)
                    },
                    onDelete: { item in
                        viewModel.removeItem(with: item.productId)
                    },
                    rowContent: { item in
                        FavoritesRowView(
                            item: item,
                            isInCart: inCartIds.contains(item.productId),
                            priceText: viewModel.formattedPrice(item.price),
                            onToggleCart: {
                                viewModel.toggleCart(for: item.productId)
                            }
                        )
                    }
                )
            }
        }
        .navigationTitle(L10n.Favorites.Navigation.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !items.isEmpty {
                    Button(L10n.Favorites.Clear.title) {
                        showClearConfirm = true
                    }
                }
            }
        }
        .confirmationDialog(
            L10n.Favorites.Clear.Confirm.title,
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Favorites.Clear.title, role: .destructive) {
                viewModel.clearFavorites()
            }
            Button(L10n.Common.ok, role: .cancel) {}
        }
        .onAppear {
            bindIfNeeded()
        }
    }
}

// MARK: - Bindings

private extension FavoritesView {
    
    func bindIfNeeded() {
        guard bag.isEmpty else { return }
        
        viewModel.favoriteItemsPublisher
            .receive(on: RunLoop.main)
            .sink { items in
                self.items = items
            }
            .store(in: &bag)
        
        viewModel.inCartIdsPublisher
            .receive(on: RunLoop.main)
            .sink { ids in
                self.inCartIds = ids
            }
            .store(in: &bag)
    }
}
