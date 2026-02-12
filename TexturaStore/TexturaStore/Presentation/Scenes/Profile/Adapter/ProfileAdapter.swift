//
//  ProfileAdapter.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 09.02.2026.
//

import Foundation
import SwiftUI
import Combine

extension ProfileUserView {
    
    @MainActor
    final class ProfileAdapter: ObservableObject {
        
        let viewModel: ProfileUserViewModelProtocol
        
        @Published var userName: String = "—"
        @Published var userEmail: String = "—"
        
        var rows: [ProfileUserRow] { viewModel.rows }
        
        private var bag = Set<AnyCancellable>()
        
        init(viewModel: ProfileUserViewModelProtocol) {
            self.viewModel = viewModel
            
            viewModel.userNamePublisher
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.userName = $0 }
                .store(in: &bag)
            
            viewModel.userEmailPublisher
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.userEmail = $0 }
                .store(in: &bag)
        }
    }
}
