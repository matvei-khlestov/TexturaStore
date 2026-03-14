//
//  ContactItem.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.02.2026.
//

import Foundation

enum ContactItem: CaseIterable {
    case phone
    case email
    case address
    
    var icon: String {
        switch self {
        case .phone:   "phone.fill"
        case .email:   "envelope.fill"
        case .address: "mappin.and.ellipse"
        }
    }
    
    var title: String {
        switch self {
        case .phone:   L10n.Contact.Item.Phone.title
        case .email:   L10n.Contact.Item.Email.title
        case .address: L10n.Contact.Item.Address.title
        }
    }
    
    var detail: String {
        switch self {
        case .phone:   L10n.Contact.Item.Phone.detail
        case .email:   L10n.Contact.Item.Email.detail
        case .address: L10n.Contact.Item.Address.detail
        }
    }
    
    var action: () -> Void {
        switch self {
        case .phone:
            return { print("Нажали на телефон") }
        case .email:
            return { print("Нажали на email") }
        case .address:
            return { print("Нажали на адрес") }
        }
    }
}
