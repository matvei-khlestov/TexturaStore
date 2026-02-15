//
//  ProfileRepository.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation
import Combine

/// Протокол `ProfileRepository`
///
/// Определяет единый интерфейс для управления профилем пользователя,
/// объединяя локальное (`ProfileLocalStore`) и удалённое (`ProfileStoreProtocol`)
/// хранилища данных.
///
/// Основные задачи:
/// - реактивное наблюдение за состоянием профиля (`observeProfile`);
/// - синхронизация данных между сервером и локальным хранилищем (`refresh`);
/// - инициализация профиля при первой регистрации (`ensureInitialProfile`);
/// - обновление данных пользователя — имени, e-mail и телефона;
/// - корректная смена e-mail через Supabase Auth (`requestEmailChange`) и последующая синхронизация (`syncEmailFromAuth`).
///
/// Используется в:
/// - `ProfileUserViewModel` — для отображения и обновления данных профиля;
/// - `EditProfileViewModel`, `EditNameViewModel`, `EditEmailViewModel`, `EditPhoneViewModel`
///   — для редактирования отдельных полей профиля.
///
/// Репозиторий скрывает источник данных и обеспечивает согласованность профиля
/// между локальной и удалённой копиями через Combine и async/await.
protocol ProfileRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за локальным состоянием профиля пользователя.
    /// - Returns: Паблишер, эмитирующий объект `UserProfile?` при изменениях.
    func observeProfile() -> AnyPublisher<UserProfile?, Never>
    
    // MARK: - Commands
    
    /// Выполняет обновление профиля из удалённого источника
    /// и синхронизирует локальные данные.
    /// - Parameter uid: Уникальный идентификатор пользователя.
    func refresh(uid: String) async throws
    
    /// Создаёт профиль пользователя при первой регистрации или входе.
    /// - Parameters:
    ///   - uid: Уникальный идентификатор пользователя.
    ///   - name: Имя пользователя.
    ///   - email: Адрес электронной почты.
    func ensureInitialProfile(uid: String, name: String, email: String) async throws
    
    /// Обновляет имя пользователя.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - name: Новое имя.
    func updateName(uid: String, name: String) async throws
    
    /// Обновляет адрес электронной почты пользователя в таблице `profiles`.
    /// - Important: Для реальной смены почты в Supabase Auth используйте `requestEmailChange(email:)`.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - email: Новый e-mail.
    func updateEmail(uid: String, email: String) async throws
    
    /// Запрашивает смену e-mail через Supabase Auth (письмо подтверждения).
    /// - Parameter email: Новый e-mail.
    func requestEmailChange(email: String) async throws
    
    /// Синхронизирует `profiles.email` с актуальным e-mail из Supabase Auth.
    /// - Parameter uid: Идентификатор пользователя.
    func syncEmailFromAuth(uid: String) async throws
    
    /// Обновляет номер телефона пользователя.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - phone: Новый номер телефона.
    func updatePhone(uid: String, phone: String) async throws
}
