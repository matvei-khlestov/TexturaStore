//
//  OrdersView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI
import Combine

/// View `OrdersView` для экрана истории заказов.
///
/// Отвечает за:
/// - отображение заказов в секциях `List` (по одному заказу на секцию);
/// - биндинг данных с `OrdersViewModelProtocol` через Combine и
///   обновление UI по входящим изменениям;
/// - конфигурацию строк заказа `OrderItemRow`;
/// - формирование заголовков секций с маскировкой идентификатора заказа;
/// - локализацию отображаемого названия товара через `OrdersLocalizing`.
///
/// Взаимодействует с:
/// - `OrdersViewModelProtocol` — источник данных, форматирование цены;
/// - `OrdersLocalizing` — локализация отображаемых названий товаров;
/// - `onBack` — обратный колбэк для навигации назад.
///
/// Особенности:
/// - компактный «брендовый» заголовок секции (`VMR-XXXX…YYYY`);
/// - отсутствие бизнес-логики: view отвечает только за UI и маршрутизацию.
struct OrdersView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: OrdersViewModelProtocol
    private let localizer: any OrdersLocalizing
    
    // MARK: - State
    
    @State private var orders: [OrderEntity] = []
    @State private var reloadToken = UUID()
    @State private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        viewModel: OrdersViewModelProtocol,
        languageProvider: any LanguageProviding,
        localizer: (any OrdersLocalizing)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.localizer = localizer ?? DefaultOrdersLocalizer(languageProvider: languageProvider)
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if orders.isEmpty {
                EmptyStateView(
                    text: L10n.Orders.emptyState,
                    horizontalPadding: Metrics.Insets.emptyStateHorizontal
                )
            } else if #available(iOS 16.0, *) {
                List {
                    ForEach(0..<viewModel.sectionsCount, id: \.self) { section in
                        if let order = viewModel.order(at: section) {
                            Section {
                                ForEach(0..<viewModel.rows(in: section), id: \.self) { row in
                                    if let item = viewModel.item(section: section, row: row) {
                                        OrderItemRow(
                                            item: item,
                                            order: order,
                                            productTitle: localizer.productTitle(item.product),
                                            priceText: viewModel.formattedPrice(item.lineTotal),
                                            showsSeparator: row != viewModel.rows(in: section) - 1
                                        )
                                        .listRowInsets(EdgeInsets())
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color(uiColor: .systemBackground))
                                    }
                                }
                            } header: {
                                Text("\(L10n.Orders.Section.headerPrefix) \(Self.maskedOrderId(order.id))")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .textCase(nil)
                                    .padding(.top, Metrics.Section.headerTop)
                            }
                        }
                    }
                }
                .id(reloadToken)
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(uiColor: .systemGroupedBackground))
            } else {
                EmptyView()
            }
        }
        .navigationTitle(L10n.Orders.Navigation.title)
        .navigationBarTitleDisplayMode(.large)
        .brandBackButton {
            onBack?()
        }
        .onAppear {
            bindViewModelIfNeeded()
        }
    }
}

// MARK: - Bindings

private extension OrdersView {
    
    func bindViewModelIfNeeded() {
        guard bag.isEmpty else { return }
        
        viewModel.ordersPublisher
            .receive(on: RunLoop.main)
            .sink { orders in
                self.orders = orders
                reloadToken = UUID()
            }
            .store(in: &bag)
    }
}

// MARK: - Helpers

private extension OrdersView {
    
    static func maskedOrderId(_ id: String) -> String {
        let raw = id.replacingOccurrences(of: "-", with: "").uppercased()
        guard raw.count > 8 else { return id }
        
        let head = raw.prefix(4)
        let tail = raw.suffix(4)
        return "VMR-\(head)…\(tail)"
    }
}

// MARK: - Metrics

private extension OrdersView {
    
    enum Metrics {
        enum Insets {
            static let emptyStateHorizontal: CGFloat = 24
        }
        
        enum Section {
            static let headerTop: CGFloat = 8
        }
    }
}
