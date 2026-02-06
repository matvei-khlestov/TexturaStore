//
//  ProfileRootView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI
import Combine

struct ProfileRootView: View {
    
    private let viewModel: any ProfileViewModelProtocol
    let onLogout: () -> Void
    
    @State private var bag = Set<AnyCancellable>()
    @State private var errorMessage: String? = nil
    
    init(
        viewModel: any ProfileViewModelProtocol,
        onLogout: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onLogout = onLogout
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Профиль")
                .font(.title)
                .fontWeight(.bold)
            
            Button("Выйти") {
                viewModel.signOut()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Профиль")
        .onAppear {
            bindIfNeeded()
        }
        .alert("Ошибка", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func bindIfNeeded() {
        guard bag.isEmpty else { return }
        
        viewModel.logoutSuccess
            .receive(on: RunLoop.main)
            .sink { [onLogout] in
                onLogout()
            }
            .store(in: &bag)
        
        viewModel.errorMessage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { msg in
                errorMessage = msg
            }
            .store(in: &bag)
    }
}
