//
//  FormValidator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import Foundation

struct FormValidator: FormValidatingProtocol {
    func validate(_ text: String, for field: AuthField) -> ValidationResult {
        switch field {
        case .name:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            var errors: [String] = []
            if trimmed.count < 2 {
                errors.append(L10n.Validation.Name.minLength)
            }
            return .init(isValid: errors.isEmpty, messages: errors)

        case .email:
            let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let valid = text.range(of: pattern, options: .regularExpression) != nil
            let errors = valid ? [] : [L10n.Validation.Email.invalid]
            return .init(isValid: errors.isEmpty, messages: errors)

        case .password:
            var errors: [String] = []
            let pwd = text.trimmingCharacters(in: .whitespacesAndNewlines)

            if pwd.count < 6 {
                errors.append(L10n.Validation.Password.minLength)
            }
            if pwd.range(of: #"\s"#, options: .regularExpression) != nil {
                errors.append(L10n.Validation.Password.noSpaces)
            }
            if pwd.range(of: #"^[A-Za-z0-9!@#$%]+$"#, options: .regularExpression) == nil {
                errors.append(L10n.Validation.Password.allowedChars)
            }
            if pwd.range(of: #"\d"#, options: .regularExpression) == nil {
                errors.append(L10n.Validation.Password.requireDigit)
            }
            if pwd.range(of: #"[!@#$%]"#, options: .regularExpression) == nil {
                errors.append(L10n.Validation.Password.requireSpecial)
            }
            if pwd.range(of: #"[A-Z]"#, options: .regularExpression) == nil {
                errors.append(L10n.Validation.Password.requireUppercase)
            }
            return .init(isValid: errors.isEmpty, messages: errors)

        case .phone:
            let pattern = #"^\+7\d{10}$"#
            let valid = text.range(of: pattern, options: .regularExpression) != nil
            let errors = valid ? [] : [L10n.Validation.Phone.invalidFormat]
            return .init(isValid: errors.isEmpty, messages: errors)

        case .comment:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            var errors: [String] = []
            if trimmed.isEmpty {
                errors.append(L10n.Validation.Comment.empty)
            }
            if trimmed.count < 3 {
                errors.append(L10n.Validation.Comment.tooShort)
            }
            if trimmed.count > 500 {
                errors.append(L10n.Validation.Comment.tooLong)
            }
            return .init(isValid: errors.isEmpty, messages: errors)
        }
    }
}
