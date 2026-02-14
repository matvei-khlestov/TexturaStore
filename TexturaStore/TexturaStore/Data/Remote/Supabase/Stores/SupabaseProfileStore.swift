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
            if existing.email != email {
                try await updateEmail(uid: uid, email: email)
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
            
            return try decodeProfile(from: response.data)
            
        } catch {
            if isNoRowsError(error) {
                return nil
            }
            throw error
        }
    }
    
    // MARK: - Updates
    
    func updateName(uid: String, name: String) async throws {
        let payload = ProfileUpdatePayload(name: name, email: nil, phone: nil)
        try await update(uid: uid, payload: payload)
    }
    
    func updateEmail(uid: String, email: String) async throws {
        let payload = ProfileUpdatePayload(name: nil, email: email, phone: nil)
        try await update(uid: uid, payload: payload)
    }
    
    func updatePhone(uid: String, phone: String) async throws {
        let payload = ProfileUpdatePayload(name: nil, email: nil, phone: phone)
        try await update(uid: uid, payload: payload)
    }
    
    private func update(uid: String, payload: ProfileUpdatePayload) async throws {
        _ = try await supabase
            .from("profiles")
            .update(payload)
            .eq("id", value: uid)
            .execute()
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
    
    static let iso8601Fractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    static let iso8601Plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    
    static let postgresFallback: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        return f
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { d in
            let c = try d.singleValueContainer()
            let s = try c.decode(String.self)
            
            if let date = iso8601Fractional.date(from: s) { return date }
            if let date = iso8601Plain.date(from: s) { return date }
            if let date = postgresFallback.date(from: s) { return date }
            
            throw DecodingError.dataCorruptedError(
                in: c,
                debugDescription: "Expected ISO8601 date, got: \(s)"
            )
        }
        return decoder
    }()
    
    func decodeProfile(from data: Data) throws -> ProfileDTO {
        try Self.decoder.decode(ProfileDTO.self, from: data)
    }
    
    /// Исправлено под текущий `ProfileDTO`:
    /// - `id` -> `userId: String`
    /// - `created_at` не нужен (в DTO его нет)
    /// - `updated_at` парсим в `Date`
    func decodeProfileFromRecord(_ record: [String: Any]) -> ProfileDTO? {
        guard
            let userId = Self.string(from: record["id"]),
            let updatedAtString = Self.string(from: record["updated_at"]),
            let updatedAt = Self.parseDate(updatedAtString)
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
    
    static func parseDate(_ s: String) -> Date? {
        iso8601Fractional.date(from: s)
        ?? iso8601Plain.date(from: s)
        ?? postgresFallback.date(from: s)
    }
    
    static func string(from value: Any?) -> String? {
        if let s = value as? String { return s }
        if let u = value as? UUID { return u.uuidString }
        if let s = value as? NSString { return s as String }
        
        if let v = value as? AnyJSON {
            if case .string(let s) = v { return s }
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

// MARK: - Errors

private extension SupabaseProfileStore {
    
    func isNoRowsError(_ error: Error) -> Bool {
        let ns = error as NSError
        let text = [
            ns.localizedDescription,
            ns.localizedFailureReason ?? "",
            ns.localizedRecoverySuggestion ?? "",
            String(describing: error)
        ]
            .joined(separator: " | ")
            .lowercased()
        
        return text.contains("no rows")
        || text.contains("multiple (or no) rows returned")
        || text.contains("json object requested")
        || text.contains("pgrst116")
    }
}
