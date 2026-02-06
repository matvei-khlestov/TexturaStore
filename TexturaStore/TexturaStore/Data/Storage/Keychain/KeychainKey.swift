//
//  KeychainKey.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 06.02.2026.
//

import Foundation

/// Ключи для хранения в Keychain.
/// Для произвольных ключей используй `.custom("some.key")`.
enum KeychainKey: Hashable {
    case userId
    case authProvider
    case receiverPhoneE164
    case deliveryAddress
    case custom(String)
    
    var rawValue: String {
        switch self {
        case .userId:
            return "auth.userId"
        case .authProvider:
            return "auth.provider"
        case .receiverPhoneE164:
            return "checkout.receiverPhoneE164"
        case .deliveryAddress:
            return "checkout.deliveryAddress"
        case .custom(let key):
            return key
        }
    }
}
