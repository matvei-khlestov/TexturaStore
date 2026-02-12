//
//  ProfileUserViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 07.02.2026.
//

import Foundation
import Combine

/// Протокол ViewModel для экрана профиля пользователя.
///
/// Отвечает за предоставление данных профиля, управление действиями выхода и удаления аккаунта,
/// а также за загрузку локального аватара пользователя.
protocol ProfileUserViewModelProtocol: AnyObject {
    
    // MARK: - Outputs
    
    /// Паблишер с именем пользователя.
    var userNamePublisher: AnyPublisher<String, Never> { get }
    
    /// Паблишер с e-mail пользователя.
    var userEmailPublisher: AnyPublisher<String, Never> { get }
    
    /// Массив строк для отображения в таблице профиля.
    var rows: [ProfileUserRow] { get }
    
    // MARK: - Actions
    
    /// Выполняет выход из аккаунта пользователя.
    func logout() async throws
    
    /// Выполняет удаление учётной записи пользователя.
    func deleteAccount() async throws
    
    /// Загружает данные аватара пользователя.
    func loadAvatarData() -> Data?
}
