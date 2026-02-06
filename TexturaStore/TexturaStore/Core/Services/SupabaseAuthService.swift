//
//  SupabaseAuthService.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 04.02.2026.
//

import Foundation
import Combine
import Supabase

/// Сервис авторизации `SupabaseAuthService`.
///
/// Реализация `AuthServiceProtocol` поверх Supabase Auth (email/password).
///
/// Особенности:
/// - `isAuthorizedPublisher` обновляется реактивно через `authStateChanges`;
/// - `currentUserId` берётся из `session.user.id`;
/// - хранит локальную сессию через `AuthSessionStoringProtocol` (Keychain);
/// - считает пользователя “авторизованным” только если email подтверждён.
///
/// Требования к Supabase:
/// - Включён Email provider.
/// - Email confirmation включена/настроена согласно политике проекта.
final class SupabaseAuthService: AuthServiceProtocol {

    // MARK: - Publishers

    private let isAuthorizedSubject = CurrentValueSubject<Bool, Never>(false)

    var isAuthorizedPublisher: AnyPublisher<Bool, Never> {
        isAuthorizedSubject.eraseToAnyPublisher()
    }

    // MARK: - State

    private(set) var currentUserId: String? = nil

    private var authEventsTask: Task<Void, Never>?

    // MARK: - Deps

    private let supabase: SupabaseClient
    private let session: AuthSessionStoringProtocol

    // MARK: - Init

    init(
        supabase: SupabaseClient,
        session: AuthSessionStoringProtocol
    ) {
        self.supabase = supabase
        self.session = session
        startAuthStateListening()
    }

    deinit {
        authEventsTask?.cancel()
        authEventsTask = nil
    }

    // MARK: - AuthServiceProtocol

    func signIn(email: String, password: String) async throws {
        do {
            _ = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            try await syncFromCurrentSessionIfPossible()
        } catch {
            throw mapSupabaseAuthError(error)
        }
    }

    func signUp(email: String, password: String) async throws {
        do {
            _ = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            // После signUp часто сессии ещё нет / email не подтверждён.
            // Явно переводим в “не авторизован” и чистим локальную сессию.
            applyAuthState(session: nil)

        } catch {
            throw mapSupabaseAuthError(error)
        }
    }

    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            applyAuthState(session: nil)
        } catch {
            throw mapSupabaseAuthError(error)
        }
    }

    func deleteAccount() async throws {
        // В Supabase удаление пользователя — это Admin API (service role).
        // На клиенте держать service role ключ НЕЛЬЗЯ.
        throw AuthDomainError.requiresBackendForAccountDeletion
    }

    func updateEmail(to newEmail: String, currentPassword: String) async throws {
        let password = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        if password.isEmpty { throw AuthDomainError.invalidCredentials }

        do {
            // Реаутентификация (логически обеспечиваем “recent login”).
            let session = try await supabase.auth.session
            let currentEmail = session.user.email ?? ""
            if currentEmail.isEmpty { throw AuthDomainError.unknown }

            _ = try await supabase.auth.signIn(email: currentEmail, password: password)

            // Обновление email через updateUser
            _ = try await supabase.auth.update(
                user: UserAttributes(email: newEmail)
            )

            try await syncFromCurrentSessionIfPossible()
        } catch {
            throw mapSupabaseAuthError(error)
        }
    }
}

// MARK: - Private: Auth state

private extension SupabaseAuthService {

    func startAuthStateListening() {
        authEventsTask?.cancel()

        authEventsTask = Task { [weak self] in
            guard let self else { return }

            // Синхронизация на старте
            await self.safeInitialSync()

            // Реактивные события
            for await (_, session) in self.supabase.auth.authStateChanges {
                if Task.isCancelled { return }
                self.applyAuthState(session: session)
            }
        }
    }

    func safeInitialSync() async {
        do {
            try await syncFromCurrentSessionIfPossible()
        } catch {
            applyAuthState(session: nil)
        }
    }

    func syncFromCurrentSessionIfPossible() async throws {
        let session = try await supabase.auth.session
        applyAuthState(session: session)
    }

    func applyAuthState(session: Session?) {
        guard let session, !session.isExpired else {
            currentUserId = nil
            isAuthorizedSubject.send(false)
            self.session.clearSession()
            return
        }

        // Не пускаем в “авторизован” пока email не подтверждён
        guard session.user.emailConfirmedAt != nil else {
            currentUserId = nil
            isAuthorizedSubject.send(false)
            self.session.clearSession()
            return
        }

        let userId = session.user.id.uuidString
        currentUserId = userId
        isAuthorizedSubject.send(true)

        // Сохраняем сессию в Keychain
        self.session.saveSession(userId: userId, provider: "email")
    }
}

// MARK: - Error mapping

private extension SupabaseAuthService {

    enum AuthDomainError: LocalizedError {
        case invalidCredentials
        case emailAlreadyInUse
        case weakPassword
        case network
        case rateLimited
        case requiresBackendForAccountDeletion
        case unknown

        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Неверный email или пароль."
            case .emailAlreadyInUse:
                return "Email уже используется."
            case .weakPassword:
                return "Слишком простой пароль."
            case .network:
                return "Проблема с сетью."
            case .rateLimited:
                return "Слишком много попыток. Попробуйте позже."
            case .requiresBackendForAccountDeletion:
                return "Удаление аккаунта требует серверной операции (Admin API Supabase)."
            case .unknown:
                return "Неизвестная ошибка."
            }
        }
    }

    func mapSupabaseAuthError(_ error: Error) -> Error {
        let ns = error as NSError
        let underlying = (ns.userInfo[NSUnderlyingErrorKey] as? NSError)
        let root = underlying ?? ns

        // 1) Network (URLSession)
        if root.domain == NSURLErrorDomain {
            switch root.code {
            case NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorDNSLookupFailed,
                 NSURLErrorNotConnectedToInternet,
                 NSURLErrorTimedOut,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorInternationalRoamingOff,
                 NSURLErrorCallIsActive,
                 NSURLErrorDataNotAllowed,
                 NSURLErrorSecureConnectionFailed,
                 NSURLErrorCannotLoadFromNetwork:
                return AuthDomainError.network

            case NSURLErrorCancelled:
                return AuthDomainError.unknown

            default:
                return AuthDomainError.network
            }
        }

        // 2) Text pool (устойчивее к локализации/обёрткам SDK)
        let candidates = [
            root.localizedDescription,
            root.localizedFailureReason,
            root.localizedRecoverySuggestion,
            ns.localizedDescription,
            String(describing: error)
        ]
            .compactMap { $0?.lowercased() }
            .joined(separator: " | ")

        // 3) HTTP status hints
        if candidates.contains("429") { return AuthDomainError.rateLimited }
        if candidates.contains("401") { return AuthDomainError.invalidCredentials }
        if candidates.contains("409") { return AuthDomainError.emailAlreadyInUse }

        // 4) Supabase/auth semantics
        if candidates.contains("invalid login")
            || candidates.contains("invalid credentials")
            || candidates.contains("invalid email or password")
            || candidates.contains("invalid_grant") {
            return AuthDomainError.invalidCredentials
        }

        if candidates.contains("email") && (candidates.contains("already") || candidates.contains("registered") || candidates.contains("exists")) {
            return AuthDomainError.emailAlreadyInUse
        }

        if candidates.contains("password") && (candidates.contains("weak") || candidates.contains("too short") || candidates.contains("length")) {
            return AuthDomainError.weakPassword
        }

        if candidates.contains("rate")
            || candidates.contains("too many")
            || candidates.contains("over_request_rate_limit") {
            return AuthDomainError.rateLimited
        }

        if candidates.contains("network") || candidates.contains("offline") || candidates.contains("timed out") {
            return AuthDomainError.network
        }

        return AuthDomainError.unknown
    }
}
