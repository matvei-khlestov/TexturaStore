//
//  AuthRootView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI

struct AuthRootView: View {

    let onAuthSuccess: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Авторизация")
                .font(.title)
                .fontWeight(.bold)

            Button("Войти (заглушка)") {
                onAuthSuccess()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Вход")
    }
}
