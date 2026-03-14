//
//  SupabaseRealtimeListener.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation
import Combine
import Supabase

enum SupabaseRealtimeListener {
    
    static func listen<T: Sendable>(
        supabase: SupabaseClient,
        channelName: String,
        table: String,
        fetch: @escaping @Sendable () async -> [T]
    ) -> AnyPublisher<[T], Never> {
        let subject = PassthroughSubject<[T], Never>()
        let channel = supabase.channel(channelName)
        
        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: table
        )
        
        let task = Task {
            let initial = await fetch()
            subject.send(initial)
            
            do {
                try await channel.subscribeWithError()
            } catch {
                return
            }
            
            for await _ in changes {
                let updated = await fetch()
                subject.send(updated)
            }
            
            await channel.unsubscribe()
        }
        
        return subject
            .handleEvents(
                receiveCancel: {
                    task.cancel()
                    Task {
                        await channel.unsubscribe()
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
