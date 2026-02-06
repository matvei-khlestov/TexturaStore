//
//  ProfileViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import Foundation
import Combine

/// Контракт ViewModel для экрана профиля.
///
/// Отвечает за:
/// - выход пользователя из аккаунта;
/// - публикацию события успешного логаута;
/// - обработку ошибок выхода.
protocol ProfileViewModelProtocol: AnyObject {
    
    // MARK: - Outputs
    
    /// Событие успешного выхода из аккаунта.
    var logoutSuccess: AnyPublisher<Void, Never> { get }
    
    /// Ошибка при выходе из аккаунта.
    var errorMessage: AnyPublisher<String?, Never> { get }
    
    // MARK: - Actions
    
    /// Выполняет выход пользователя из аккаунта.
    func signOut()
}
