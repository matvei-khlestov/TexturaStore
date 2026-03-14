//
//  Container+SupabaseClient.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 04.02.2026.
//

import FactoryKit
import Supabase

extension Container {

    var supabaseClient: Factory<SupabaseClient> {
        Factory(self) { @MainActor in
            SupabaseClientFactory.make()
        }
        .scope(.singleton)
    }
}

