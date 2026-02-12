//
//  SupabaseAuthService.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 04.02.2026.
//

import Foundation
import Combine
import Supabase

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
    
    func signUp(email: String, password: String, name: String) async throws {
        do {
            _ = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "name": AnyJSON.string(name)
                ]
            )
            
            // После signUp при включённой email confirmation часто нет активной сессии.
            // Считаем не авторизованным.
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
        throw AuthDomainError.requiresBackendForAccountDeletion
    }
}

// MARK: - Private: Auth state

private extension SupabaseAuthService {
    
    func startAuthStateListening() {
        authEventsTask?.cancel()
        
        authEventsTask = Task { [weak self] in
            guard let self else { return }
            
            await self.safeInitialSync()
            
            for await (_, session) in self.supabase.auth.authStateChanges {
                if Task.isCancelled { return }
                self.applyAuthState(session: session)
            }
        }
    }
    
    func safeInitialSync() async {
        do {
            // 1) Пробуем обычный путь (если Supabase сам сохранил/восстановил сессию)
            try await syncFromCurrentSessionIfPossible()
            return
        } catch {
            // 2) Если нет — пробуем восстановить из Keychain (access/refresh)
            do {
                if let access = session.accessToken,
                   let refresh = session.refreshToken,
                   !access.isEmpty,
                   !refresh.isEmpty {
                    
                    _ = try await supabase.auth.setSession(
                        accessToken: access,
                        refreshToken: refresh
                    )
                    
                    try await syncFromCurrentSessionIfPossible()
                    return
                }
            } catch {
                // если токены протухли / невалидны — чистим
                self.session.clearSession()
            }
            
            // 3) Итог: не авторизован
            applyAuthState(session: nil)
        }
    }
    
    func syncFromCurrentSessionIfPossible() async throws {
        let session = try await supabase.auth.session
        applyAuthState(session: session)
    }
    
    func applyAuthState(session: Session?) {
        // 0) Сессии нет / она протухла -> чистим
        guard let session, !session.isExpired else {
            currentUserId = nil
            isAuthorizedSubject.send(false)
            self.session.clearSession()
            return
        }
        
        let userId = session.user.id.uuidString.lowercased()
        currentUserId = userId
        
        self.session.saveSession(
            userId: userId,
            provider: "email",
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
        )
        
        // 3) Авторизованность = подтверждён ли email
        let isConfirmed = (session.user.emailConfirmedAt != nil)
        isAuthorizedSubject.send(isConfirmed)
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
        
        let candidates = [
            root.localizedDescription,
            root.localizedFailureReason,
            root.localizedRecoverySuggestion,
            ns.localizedDescription,
            String(describing: error)
        ]
            .compactMap { $0?.lowercased() }
            .joined(separator: " | ")
        
        if candidates.contains("429") { return AuthDomainError.rateLimited }
        if candidates.contains("401") { return AuthDomainError.invalidCredentials }
        if candidates.contains("409") { return AuthDomainError.emailAlreadyInUse }
        
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
