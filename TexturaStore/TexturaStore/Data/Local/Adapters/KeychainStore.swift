//
//  KeychainStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation

struct KeychainStore: SecretsStore {
    private let kc: KeychainServiceProtocol
    init(_ kc: KeychainServiceProtocol = KeychainService()) { self.kc = kc }
    func set(_ value: String, for key: KeychainKey) -> Bool { kc.set(value, for: key) }
    func get(_ key: KeychainKey) -> String? { kc.get(key) }
    func remove(_ key: KeychainKey) -> Bool { kc.remove(key) }
}
