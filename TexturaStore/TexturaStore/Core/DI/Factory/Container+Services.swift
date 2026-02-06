//
//  Container+Services.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 04.02.2026.
//

import Foundation
import FactoryKit
import Supabase

extension Container {

    // MARK: - Auth

    var authService: Factory<AuthServiceProtocol> {
        Factory(self) { @MainActor in
            SupabaseAuthService(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
}
