//
//  OrderDTO.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation

/// Data Transfer Object, описывающий заказ (`OrderDTO`) в слое данных.
///
/// Назначение:
/// - используется для передачи сериализуемых данных заказа между Data и Domain слоями;
/// - изолирует формат хранения/получения заказа от доменной модели `OrderEntity`;
/// - участвует в маппинге заказа и его позиций в бизнес-сущности.
///
/// Состав:
/// - `id`: уникальный идентификатор заказа;
/// - `userId`: идентификатор пользователя;
/// - `createdAt`, `updatedAt`: даты создания и обновления заказа;
/// - `status`: текущий статус заказа;
/// - `receiveAddress`: адрес получения заказа;
/// - `paymentMethod`: способ оплаты;
/// - `comment`: комментарий к заказу;
/// - `phoneE164`: номер телефона в формате E.164;
/// - `items`: список позиций заказа.
///
/// Особенности реализации:
/// - поддерживает `Codable` для декодирования JSON;
/// - используется в слое Data;
/// - преобразуется в доменную модель через `toEntity()`.
struct OrderDTO: Codable, Equatable {
    
    // MARK: - Properties
    
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    let status: OrderStatus
    let receiveAddress: String
    let paymentMethod: String
    let comment: String?
    let phoneE164: String?
    let items: [OrderItemDTO]
    
    // MARK: - Mapping
    
    func toEntity() -> OrderEntity {
        OrderEntity(
            id: id,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            status: status,
            receiveAddress: receiveAddress,
            paymentMethod: paymentMethod,
            comment: comment ?? "",
            phoneE164: phoneE164,
            items: items.map {
                $0.toEntity(
                    createdAt: createdAt,
                    updatedAt: updatedAt
                )
            }
        )
    }
}

// MARK: - CodingKeys

private extension OrderDTO {
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case status
        case receiveAddress = "receive_address"
        case paymentMethod = "payment_method"
        case comment
        case phoneE164 = "phone_e164"
        case items
    }
}
