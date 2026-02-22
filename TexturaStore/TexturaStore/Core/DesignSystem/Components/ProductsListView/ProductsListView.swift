//
//  ProductsListView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

/// Универсальный список товаров для экранов вроде Cart/Favorites.
/// Рендер строки делегируется через `rowContent`, чтобы не ломать текущие RowView.
struct ProductsListView<Item, ID: Hashable>: View {
    
    let items: [Item]
    let id: KeyPath<Item, ID>
    
    let deleteTitle: String
    
    let onSelect: (Item) -> Void
    let onDelete: (Item) -> Void
    
    private let rowContent: (Item) -> AnyView
    
    init(
        items: [Item],
        id: KeyPath<Item, ID>,
        deleteTitle: String,
        onSelect: @escaping (Item) -> Void,
        onDelete: @escaping (Item) -> Void,
        @ViewBuilder rowContent: @escaping (Item) -> some View
    ) {
        self.items = items
        self.id = id
        self.deleteTitle = deleteTitle
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.rowContent = { AnyView(rowContent($0)) }
    }
    
    var body: some View {
        List {
            ForEach(items, id: id) { item in
                Button {
                    onSelect(item)
                } label: {
                    rowContent(item)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDelete(item)
                    } label: {
                        Text(deleteTitle)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}
