//
//  MainTabRootView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI

struct MainTabRootView: View {

    @Binding var selectedTab: MainTab

    let catalogRoot: AnyView
    let favoritesRoot: AnyView
    let cartRoot: AnyView
    let profileRoot: AnyView

    var body: some View {
        TabView(selection: $selectedTab) {

            catalogRoot
                .tabItem { Label(L10n.Tab.catalog, systemImage: "square.grid.2x2") }
                .tag(MainTab.catalog)

            favoritesRoot
                .tabItem { Label(L10n.Tab.favorites, systemImage: "heart") }
                .tag(MainTab.favorites)

            cartRoot
                .tabItem { Label(L10n.Tab.cart, systemImage: "cart") }
                .tag(MainTab.cart)

            profileRoot
                .tabItem { Label(L10n.Tab.profile, systemImage: "person") }
                .tag(MainTab.profile)
        }
        .tint(.brandPrimary)
    }
}
