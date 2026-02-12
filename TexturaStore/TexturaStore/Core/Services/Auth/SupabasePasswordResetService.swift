//
//  SupabasePasswordResetService.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import Foundation
import Supabase

/// Сервис восстановления пароля `SupabasePasswordResetService`
/// — реализация `PasswordResetServiceProtocol` на основе Supabase Auth.
///
/// Назначение:
/// - отправка письма для сброса пароля по указанному e-mail (`sendPasswordReset`);
/// - обработка и маппинг ошибок Supabase в доменные ошибки.
///
/// Поведение:
/// - вызывает `supabase.auth.resetPasswordForEmail(...)`;
/// - Supabase по умолчанию может возвращать успех даже если email не зарегистрирован
///   (защита от enumeration), поэтому ошибка `userNotFound` не гарантируется.
final class SupabasePasswordResetService: PasswordResetServiceProtocol {

    // MARK: - Deps

    private let supabase: SupabaseClient
    private let redirectURL: URL?

    // MARK: - Init

    init(
        supabase: SupabaseClient,
        redirectURL: URL? = nil
    ) {
        self.supabase = supabase
        self.redirectURL = redirectURL
    }

    // MARK: - Public API

    func sendPasswordReset(email: String) async throws {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ResetDomainError.invalidEmail }

        do {
            if let redirectURL {
                try await supabase.auth.resetPasswordForEmail(
                    trimmed,
                    redirectTo: redirectURL
                )
            } else {
                try await supabase.auth.resetPasswordForEmail(trimmed)
            }
        } catch {
            throw mapSupabaseAuthError(error)
        }
    }
}

// MARK: - Error mapping

private extension SupabasePasswordResetService {

    enum ResetDomainError: LocalizedError {
        case invalidEmail
        case tooManyRequests
        case network
        case unknown

        var errorDescription: String? {
            switch self {
            case .invalidEmail:
                return "Некорректный e-mail."
            case .tooManyRequests:
                return "Слишком много попыток. Попробуйте позже."
            case .network:
                return "Проблема с сетью."
            case .unknown:
                return "Неизвестная ошибка."
            }
        }
    }

    func mapSupabaseAuthError(_ error: Error) -> Error {
        let ns = error as NSError
        let underlying = (ns.userInfo[NSUnderlyingErrorKey] as? NSError)
        let root = underlying ?? ns

        // 1) Network
        if root.domain == NSURLErrorDomain {
            switch root.code {
            case NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorDNSLookupFailed,
                 NSURLErrorNotConnectedToInternet,
                 NSURLErrorTimedOut,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorSecureConnectionFailed,
                 NSURLErrorCannotLoadFromNetwork:
                return ResetDomainError.network
            default:
                return ResetDomainError.network
            }
        }

        // 2) Текстовые подсказки (устойчивее к обёрткам SDK)
        let candidates = [
            root.localizedDescription,
            root.localizedFailureReason,
            root.localizedRecoverySuggestion,
            ns.localizedDescription,
            String(describing: error)
        ]
            .compactMap { $0?.lowercased() }
            .joined(separator: " | ")

        // 3) Rate limit
        if candidates.contains("429")
            || candidates.contains("too many")
            || candidates.contains("rate")
            || candidates.contains("over_request_rate_limit") {
            return ResetDomainError.tooManyRequests
        }

        // 4) Invalid email
        if candidates.contains("email") && (candidates.contains("invalid") || candidates.contains("malformed")) {
            return ResetDomainError.invalidEmail
        }

        // 5) Network hints
        if candidates.contains("network") || candidates.contains("offline") || candidates.contains("timed out") {
            return ResetDomainError.network
        }

        return ResetDomainError.unknown
    }
}
