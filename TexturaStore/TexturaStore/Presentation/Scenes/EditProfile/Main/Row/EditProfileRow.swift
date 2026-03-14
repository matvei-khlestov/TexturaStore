//
//  EditProfileRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import Foundation

enum EditProfileRow: Int, CaseIterable {
    case name
    case email
    case phone
    
    var icon: String {
        switch self {
        case .name:  "person.fill"
        case .email: "envelope.fill"
        case .phone: "phone.fill"
        }
    }
    
    var title: String {
        switch self {
        case .name:  L10n.Profile.Edit.Row.name
        case .email: L10n.Profile.Edit.Row.email
        case .phone: L10n.Profile.Edit.Row.phone
        }
    }
    
    func detail(from vm: EditProfileViewModelProtocol) -> String {
        switch self {
        case .name:  vm.name
        case .email: vm.email
        case .phone: vm.phone
        }
    }
}
