//
//  OrderEntity.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation

enum OrderStatus: String, Codable, Equatable {
    case assembling
    case ready
    case delivering
    case delivered
    case cancelled

    var badgeText: String {
        switch self {
        case .assembling:
            return L10n.Orders.Status.assembling
        case .ready:
            return L10n.Orders.Status.ready
        case .delivering:
            return L10n.Orders.Status.delivering
        case .delivered:
            return L10n.Orders.Status.delivered
        case .cancelled:
            return L10n.Orders.Status.cancelled
        }
    }
}

struct OrderEntity: Equatable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    let status: OrderStatus
    let receiveAddress: String
    let paymentMethod: String
    let comment: String
    let phoneE164: String?
    let items: [OrderItem]
}
