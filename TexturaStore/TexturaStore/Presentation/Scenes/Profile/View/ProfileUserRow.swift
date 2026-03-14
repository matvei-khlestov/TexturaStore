//
//  ProfileUserRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation

enum ProfileUserRow: Int, CaseIterable {
    case editProfile
    case orders
    case settings
    case about
    case contact
    case privacy
    
    var title: String {
        switch self {
        case .editProfile:
            return L10n.Profile.Menu.editProfile
        case .orders:
            return L10n.Profile.Menu.orders
        case .settings:
            return L10n.Profile.Menu.settings
        case .about:
            return L10n.Profile.Menu.about
        case .contact:
            return L10n.Profile.Menu.contact
        case .privacy:
            return L10n.Profile.Menu.privacy
        }
    }
    
    var systemImage: String {
        switch self {
        case .editProfile: return "person.crop.circle.badge.plus"
        case .orders:      return "bag.fill"
        case .settings:    return "gearshape.fill"
        case .about:       return "storefront.fill"
        case .contact:     return "phone.fill"
        case .privacy:     return "lock.shield.fill"
        }
    }
}
