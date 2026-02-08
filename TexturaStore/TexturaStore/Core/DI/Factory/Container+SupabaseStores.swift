//
//  Container+SupabaseStores.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation
import FactoryKit
import Supabase

extension Container {
    
    
    // MARK: - Profile
    
    var profileStore: Factory<any ProfileStoreProtocol> {
        Factory(self) { @MainActor in
            SupabaseProfileStore(
                supabase: self.supabaseClient()
            )
        }
        .scope(.singleton)
    }
}
