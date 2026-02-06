//
//  ProfileViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import Foundation
import Combine

final class ProfileViewModel: ProfileViewModelProtocol {

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    // MARK: - Subjects

    private let logoutSuccessSubject = PassthroughSubject<Void, Never>()
    private let errorMessageSubject = CurrentValueSubject<String?, Never>(nil)

    // MARK: - Init

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Outputs

    var logoutSuccess: AnyPublisher<Void, Never> {
        logoutSuccessSubject.eraseToAnyPublisher()
    }

    var errorMessage: AnyPublisher<String?, Never> {
        errorMessageSubject.eraseToAnyPublisher()
    }

    // MARK: - Actions

    func signOut() {
        Task {
            do {
                try await authService.signOut()
                logoutSuccessSubject.send(())
            } catch {
                errorMessageSubject.send(error.localizedDescription)
            }
        }
    }
}
