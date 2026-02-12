//
//  LocalizationManager.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class LocalizationManager: ObservableObject {

    static let shared = LocalizationManager()

    @Published private(set) var language: AppLanguage
    @Published private(set) var reloadToken: UUID = UUID()

    private init() {
        self.language = .ru
        Bundle.setAppLanguage(.ru)
    }

    var locale: Locale {
        Locale(identifier: language.rawValue)
    }

    func apply(language: AppLanguage) {
        guard self.language != language else { return }

        Bundle.setAppLanguage(language)

        Task { @MainActor in
            self.language = language
            self.reloadToken = UUID()
        }
    }
}
