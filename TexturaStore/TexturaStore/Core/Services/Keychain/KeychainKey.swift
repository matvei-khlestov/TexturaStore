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
    
    // MARK: - Auth
    
    case userId
    case authProvider
    case accessToken
    case refreshToken
    
    // MARK: - Checkout
    
    case receiverPhoneE164
    case deliveryAddress
    
    // MARK: - Custom
    
    case custom(String)
    
    // MARK: - Raw value
    
    var rawValue: String {
        switch self {
        case .userId:
            return "auth.userId"
        case .authProvider:
            return "auth.provider"
        case .accessToken:
            return "auth.accessToken"
        case .refreshToken:
            return "auth.refreshToken"
        case .receiverPhoneE164:
            return "checkout.receiverPhoneE164"
        case .deliveryAddress:
            return "checkout.deliveryAddress"
        case .custom(let key):
            return key
        }
    }
}
