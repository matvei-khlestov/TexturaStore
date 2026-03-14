//
//  SupabaseClientFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 04.02.2026.
//

import Supabase

enum SupabaseClientFactory {
    static func make() -> SupabaseClient {
        let options = SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )

        return SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.supabaseKey,
            options: options
        )
    }
}
