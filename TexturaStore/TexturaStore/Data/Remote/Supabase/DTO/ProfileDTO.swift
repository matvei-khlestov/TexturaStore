//
//  ProfileDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation

/// Data Transfer Object, представляющий профиль пользователя (`ProfileDTO`).
///
/// Назначение:
/// - используется для обмена данными между удалёнными источниками (Supabase, REST API)
///   и внутренними слоями приложения (Domain, Persistence);
/// - обеспечивает изоляцию модели данных от бизнес-логики и UI.
///
/// Состав:
/// - `userId`: уникальный идентификатор пользователя;
/// - `name`: имя пользователя;
/// - `email`: адрес электронной почты;
/// - `phone`: номер телефона в формате строки;
/// - `updatedAt`: дата последнего обновления данных.
///
/// Особенности реализации:
/// - метод `toEntity()` преобразует DTO в доменную модель `UserProfile`;
/// - `Equatable` используется для эффективных сравнений и предотвращения лишних апдейтов.
struct ProfileDTO: Decodable, Equatable {
    
    let userId: String
    let name: String
    let email: String
    let phone: String
    let updatedAt: Date
    
    func toEntity() -> UserProfile {
        .init(
            userId: userId,
            name: name,
            email: email,
            phone: phone,
            updatedAt: updatedAt
        )
    }
    
    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case userId = "id"
        case name
        case email
        case phone
        case updatedAt = "updated_at"
    }
}
