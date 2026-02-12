//
//  SettingsViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: SettingsViewModelProtocol {

    // MARK: - State

    @Published private var _language: AppLanguage
    @Published private var _theme: AppTheme

    // MARK: - Dependencies

    private let service: any SettingsServiceProtocol
    private var bag = Set<AnyCancellable>()

    // MARK: - Init

    init(service: any SettingsServiceProtocol) {
        self.service = service
        self._language = service.language
        self._theme = service.theme

        bindService()
    }

    // MARK: - Bindings

    private func bindService() {
        service.languagePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?._language = value
            }
            .store(in: &bag)

        service.themePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?._theme = value
            }
            .store(in: &bag)
    }

    // MARK: - Current Values

    var currentLanguage: AppLanguage { _language }
    var currentTheme: AppTheme { _theme }

    // MARK: - Outputs

    var language: AnyPublisher<AppLanguage, Never> {
        $_language.eraseToAnyPublisher()
    }

    var theme: AnyPublisher<AppTheme, Never> {
        $_theme.eraseToAnyPublisher()
    }

    // MARK: - Inputs

    func setLanguage(_ value: AppLanguage) {
        service.setLanguage(value)
    }

    func setTheme(_ value: AppTheme) {
        service.setTheme(value)
    }
}
