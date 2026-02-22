//
//  LanguageProviding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import Foundation
import Combine

protocol LanguageProviding {
    var languagePublisher: AnyPublisher<AppLanguage, Never> { get }
    var currentLanguage: AppLanguage { get }
}
