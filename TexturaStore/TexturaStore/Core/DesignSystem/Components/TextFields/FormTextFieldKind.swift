//
//  FormTextFieldKind.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import Foundation

enum FormTextFieldKind {
    case name
    case email
    case password
    case phone
    
    var title: String {
        switch self {
        case .name:
            return L10n.Form.Field.Name.title
        case .email:
            return L10n.Form.Field.Email.title
        case .password:
            return L10n.Form.Field.Password.title
        case .phone:
            return L10n.Form.Field.Phone.title
        }
    }
    
    var placeholder: String {
        switch self {
        case .name:
            return L10n.Form.Field.Name.placeholder
        case .email:
            return L10n.Form.Field.Email.placeholder
        case .password:
            return L10n.Form.Field.Password.placeholder
        case .phone:
            return L10n.Form.Field.Phone.placeholder
        }
    }
}
