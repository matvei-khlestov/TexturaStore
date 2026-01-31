//
//  ProfileRootView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI

struct ProfileRootView: View {

    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Профиль")
                .font(.title)
                .fontWeight(.bold)

            Button("Выйти") {
                onLogout()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Профиль")
    }
}
