//
//  Container+Managers.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation
import FactoryKit

extension Container {
    
    var localizationManager: Factory<LocalizationManager> {
        Factory(self) { @MainActor in
            LocalizationManager.shared
        }
        .scope(.singleton)
    }
}
