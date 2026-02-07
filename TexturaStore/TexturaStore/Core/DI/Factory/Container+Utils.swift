//
//  Container+Utils.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import FactoryKit

extension Container {

    // MARK: - Utils

    var formValidator: Factory<any FormValidatingProtocol> {
        Factory(self) { @MainActor in
            FormValidator()
        }
        .scope(.singleton)
    }
}
