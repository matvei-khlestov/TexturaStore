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
            return "Имя"
        case .email:
            return "E-mail"
        case .password:
            return "Пароль"
        case .phone:
            return "Телефон"
        }
    }

    var placeholder: String {
        switch self {
        case .name:
            return "Введите имя"
        case .email:
            return "Введите e-mail"
        case .password:
            return "Введите пароль"
        case .phone:
            return "+7 (___) ___-__-__"
        }
    }
}
