//
//  CartView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI
import Combine

struct CartView: View {
    
    // MARK: - Callbacks
    
    var onCheckout: (() -> Void)?
    var onSelectProductId: ((String) -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: CartViewModelProtocol
    
    // MARK: - State
    
    @State private var items: [CartItem] = []
    @State private var bag = Set<AnyCancellable>()
    
    @State private var showClearConfirm = false
    
    // MARK: - Init
    
    init(
        viewModel: CartViewModelProtocol,
        onCheckout: (() -> Void)? = nil,
        onSelectProductId: ((String) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onCheckout = onCheckout
        self.onSelectProductId = onSelectProductId
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if items.isEmpty {
                EmptyStateView(
                    text: L10n.Cart.emptyState,
                    horizontalPadding: Metrics.Insets.emptyStateHorizontal
                )
            } else {
                ProductsListView(
                    items: items,
                    id: \.productId,
                    deleteTitle: L10n.Cart.Swipe.delete,
                    onSelect: { item in
                        onSelectProductId?(item.productId)
                    },
                    onDelete: { item in
                        viewModel.removeItem(with: item.productId)
                    },
                    rowContent: { item in
                        CartRowView(
                            item: item,
                            priceText: viewModel.formattedPrice(item.lineTotal),
                            onDecrease: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.decreaseQuantity(for: item.productId)
                            },
                            onIncrease: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.increaseQuantity(for: item.productId)
                            }
                        )
                    }
                )
            }
        }
        .navigationTitle(L10n.Cart.Navigation.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !items.isEmpty {
                    Button(L10n.Cart.Clear.title) {
                        showClearConfirm = true
                    }
                }
            }
        }
        .confirmationDialog(
            L10n.Cart.Clear.Confirm.title,
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Cart.Clear.title, role: .destructive) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.clearCart()
            }
            Button(L10n.Common.ok, role: .cancel) {}
        }
        .safeAreaInset(edge: .bottom) {
            if !items.isEmpty {
                CartCheckoutBarView(
                    onCheckout: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onCheckout?()
                    },
                    horizontalPadding: Metrics.Insets.horizontal,
                    topPadding: Metrics.Layout.BottomOverlay.topPadding,
                    bottomPadding: Metrics.Spacing.buttonBottom
                )
            }
        }
        .onAppear {
            bindIfNeeded()
        }
    }
}

// MARK: - Bindings

private extension CartView {
    
    func bindIfNeeded() {
        guard bag.isEmpty else { return }
        
        viewModel.cartItemsPublisher
            .receive(on: RunLoop.main)
            .sink { items in
                self.items = items
            }
            .store(in: &bag)
    }
}

// MARK: - Metrics

private extension CartView {
    
    enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 20
            static let verticalBottom: CGFloat = 0
            static let emptyStateHorizontal: CGFloat = 24
        }
        
        enum Spacing {
            static let buttonBottom: CGFloat = 16
        }
        
        enum Layout {
            enum BottomOverlay {
                static let topPadding: CGFloat = 16
                static let buttonHeight: CGFloat = 52
                static let bottomPadding: CGFloat = 16
            }
        }
    }
}
