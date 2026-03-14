//
//  SupabaseProfileStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation
import Combine
import Supabase

final class SupabaseProfileStore: ProfileStoreProtocol {
    
    // MARK: - Deps
    
    private let supabase: SupabaseClient
    
    // MARK: - Init
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Create / Ensure
    
    func ensureInitialUserProfile(
        uid: String,
        name: String,
        email: String
    ) async throws {
        if let existing = try await fetchProfile(uid: uid) {
            if existing.name != name {
                try await updateName(uid: uid, name: name)
            }
            return
        }
        
        let payload = ProfileInsertPayload(
            id: uid,
            name: name,
            email: email,
            phone: ""
        )
        
        _ = try await supabase
            .from("profiles")
            .insert(payload)
            .execute()
    }
    
    // MARK: - Fetch
    
    func fetchProfile(uid: String) async throws -> ProfileDTO? {
        do {
            let response = try await supabase
                .from("profiles")
                .select("id, name, email, phone, updated_at")
                .eq("id", value: uid)
                .single()
                .execute()
            
            return try SupabaseDecoding.decode(ProfileDTO.self, from: response.data)
            
        } catch {
            if SupabaseErrorMatcher.isNoRowsError(error) {
                return nil
            }
            throw error
        }
    }
    
    // MARK: - Updates
    
    func updateName(uid: String, name: String) async throws {
        let payload = ProfileUpdatePayload(name: name, email: nil, phone: nil)
        try await update(uid: uid, payload: payload)
        try await updateNameInAuthMetadata(name: name)
    }
    
    func updateEmail(uid: String, email: String) async throws {
        let payload = ProfileUpdatePayload(name: nil, email: email, phone: nil)
        try await update(uid: uid, payload: payload)
    }
    
    func updatePhone(uid: String, phone: String) async throws {
        let payload = ProfileUpdatePayload(name: nil, email: nil, phone: phone)
        try await update(uid: uid, payload: payload)
        try await updatePhoneInAuthMetadata(phoneE164: phone)
    }
    
    private func update(uid: String, payload: ProfileUpdatePayload) async throws {
        _ = try await supabase
            .from("profiles")
            .update(payload)
            .eq("id", value: uid)
            .execute()
    }
    
    // MARK: - Auth metadata
    
    private func updatePhoneInAuthMetadata(phoneE164: String) async throws {
        let trimmed = phoneE164.trimmingCharacters(in: .whitespacesAndNewlines)
        let attrs = UserAttributes(
            data: [
                "phone": .string(trimmed)
            ]
        )
        try await supabase.auth.update(user: attrs)
    }
    
    private func updateNameInAuthMetadata(name: String) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let attrs = UserAttributes(
            data: [
                "name": .string(trimmed)
            ]
        )
        try await supabase.auth.update(user: attrs)
    }
    
    // MARK: - Email Change (Supabase Auth)
    
    func requestEmailChange(
        newEmail: String,
        redirectURL: URL?
    ) async throws {
        try await supabase.auth.update(
            user: UserAttributes(email: newEmail),
            redirectTo: redirectURL
        )
    }
    
    func syncProfileEmailFromAuth(uid: String) async throws {
        _ = try? await supabase.auth.refreshSession()
        
        let user = try await supabase.auth.user()
        let authEmail = (user.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !authEmail.isEmpty else { return }
        
        let current = try await fetchProfile(uid: uid)
        let dbEmail = (current?.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard dbEmail != authEmail else { return }
        
        try await updateEmail(uid: uid, email: authEmail)
    }
    
    // MARK: - Realtime
    
    func listenProfile(uid: String) -> AnyPublisher<ProfileDTO?, Never> {
        let subject = PassthroughSubject<ProfileDTO?, Never>()
        
        let channel = supabase.channel("profiles-\(uid)")
        
        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "profiles"
        )
        
        let task = Task { [weak self] in
            guard let self else { return }
            
            do {
                try await channel.subscribeWithError()
            } catch {
                return
            }
            
            for await change in changes {
                guard
                    let record = Self.extractRecord(from: change),
                    let recordId = Self.string(from: record["id"]),
                    recordId == uid,
                    let dto = self.decodeProfileFromRecord(record)
                else {
                    continue
                }
                
                subject.send(dto)
            }
            
            await channel.unsubscribe()
        }
        
        return subject
            .handleEvents(receiveCancel: {
                task.cancel()
                Task { await channel.unsubscribe() }
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Payloads

private extension SupabaseProfileStore {
    
    struct ProfileInsertPayload: Encodable {
        let id: String
        let name: String
        let email: String
        let phone: String
    }
    
    struct ProfileUpdatePayload: Encodable {
        let name: String?
        let email: String?
        let phone: String?
    }
}

// MARK: - Decoding

private extension SupabaseProfileStore {
    
    func decodeProfileFromRecord(_ record: [String: Any]) -> ProfileDTO? {
        guard
            let userId = Self.string(from: record["id"]),
            let updatedAtString = Self.string(from: record["updated_at"]),
            let updatedAt = SupabaseDateParser.parse(updatedAtString)
        else {
            return nil
        }
        
        let name = Self.string(from: record["name"]) ?? ""
        let email = Self.string(from: record["email"]) ?? ""
        let phone = Self.string(from: record["phone"]) ?? ""
        
        return ProfileDTO(
            userId: userId,
            name: name,
            email: email,
            phone: phone,
            updatedAt: updatedAt
        )
    }
    
    static func string(from value: Any?) -> String? {
        if let string = value as? String { return string }
        if let uuid = value as? UUID { return uuid.uuidString }
        if let string = value as? NSString { return string as String }
        
        if let value = value as? AnyJSON {
            if case .string(let string) = value { return string }
        }
        
        return nil
    }
}

// MARK: - Record extraction

private extension SupabaseProfileStore {
    
    static func extractRecord(from action: Any) -> [String: Any]? {
        let mirror = Mirror(reflecting: action)
        
        if let child = mirror.children.first {
            let nested = Mirror(reflecting: child.value)
            for item in nested.children where item.label == "record" {
                return item.value as? [String: Any]
            }
        }
        
        for item in mirror.children where item.label == "record" {
            return item.value as? [String: Any]
        }
        
        return nil
    }
}
