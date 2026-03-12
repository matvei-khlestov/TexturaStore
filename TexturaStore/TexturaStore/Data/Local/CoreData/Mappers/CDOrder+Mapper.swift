//
//  CDOrder+Mapper.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation
import CoreData

/// Расширение `CDOrder`, обеспечивающее маппинг между Core Data и DTO/Entity слоями.
///
/// Содержит:
/// - `apply(dto:ctx:)` — применение данных из `OrderDTO` к Core Data объекту;
/// - `OrderEntity.init(cd:)` — преобразование Core Data сущности в доменную модель `OrderEntity`.
///
/// Используется в:
/// - `OrdersLocalStore` — для сохранения заказов в базу и их чтения в доменную модель.
extension CDOrder {
    
    /// Применяет данные из `OrderDTO` к Core Data сущности `CDOrder`.
    /// - Parameters:
    ///   - dto: DTO заказа, полученный с сервера или из репозитория.
    ///   - ctx: Контекст `NSManagedObjectContext`, в котором выполняется обновление.
    func apply(dto: OrderDTO, ctx: NSManagedObjectContext) {
        id = dto.id
        userId = dto.userId
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
        status = dto.status.rawValue
        receiveAddress = dto.receiveAddress
        paymentMethod = dto.paymentMethod
        comment = dto.comment
        phoneE164 = dto.phoneE164
        
        let existingItems = Self.extractItems(from: primitiveValue(forKey: "items"))
        existingItems.forEach { item in
            item.order = nil
            ctx.delete(item)
        }
        
        dto.items.forEach { itemDTO in
            let item = CDOrderItem(context: ctx)
            item.productId = itemDTO.productId
            item.brandName = itemDTO.brandName
            item.title = itemDTO.title
            item.price = itemDTO.price
            item.imageURL = itemDTO.imageURL
            item.quantity = Int32(itemDTO.quantity)
            item.order = self
        }
    }
    
    /// Извлекает элементы заказа из relationship `items`,
    /// безопасно обрабатывая разные runtime-представления значения.
    /// - Parameter raw: Сырое значение relationship.
    /// - Returns: Массив `CDOrderItem`.
    static func extractItems(from raw: Any?) -> [CDOrderItem] {
        switch raw {
        case let set as NSSet:
            return set.allObjects.compactMap { $0 as? CDOrderItem }
            
        case let array as [Any]:
            return array.compactMap { $0 as? CDOrderItem }
            
        case let item as CDOrderItem:
            return [item]
            
        default:
            return []
        }
    }
}

/// Расширение `OrderEntity`, предоставляющее инициализацию из `CDOrder`.
///
/// Выполняет:
/// - безопасное извлечение и валидацию данных из Core Data сущности;
/// - преобразование `CDOrderItem` → `OrderItem`;
/// - сортировку элементов по `productId` для стабильного отображения;
/// - построение итоговой доменной сущности `OrderEntity`.
extension OrderEntity {
    
    /// Инициализирует `OrderEntity` из Core Data сущности `CDOrder`.
    /// - Parameter cd: Объект `CDOrder` из Core Data.
    init?(cd: CDOrder?) {
        guard
            let cd,
            let id = cd.id,
            let uid = cd.userId,
            let createdAt = cd.createdAt,
            let statusRaw = cd.status,
            let status = OrderStatus(rawValue: statusRaw),
            let receiveAddress = cd.receiveAddress,
            let paymentMethod = cd.paymentMethod
        else {
            return nil
        }
        
        let updatedAt = cd.updatedAt ?? createdAt
        
        let cdItems = CDOrder.extractItems(from: cd.primitiveValue(forKey: "items"))
        let sortedItems = cdItems.sorted {
            ($0.productId ?? "") < ($1.productId ?? "")
        }
        
        let items: [OrderItem] = sortedItems.map { item in
            let title = item.title ?? ""
            let product = Product(
                id: item.productId ?? "",
                categoryId: "",
                brandId: item.brandName ?? "",
                colorId: "",
                price: item.price,
                imageURL: item.imageURL ?? "",
                nameRu: title,
                nameEn: title,
                descriptionRu: "",
                descriptionEn: "",
                nameLowerRu: title.lowercased(),
                nameLowerEn: title.lowercased(),
                ratingAvg: 0,
                ratingCount: 0,
                isActive: true,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            
            return OrderItem(
                product: product,
                quantity: Int(item.quantity)
            )
        }
        
        self.init(
            id: id,
            userId: uid,
            createdAt: createdAt,
            updatedAt: updatedAt,
            status: status,
            receiveAddress: receiveAddress,
            paymentMethod: paymentMethod,
            comment: cd.comment ?? "",
            phoneE164: cd.phoneE164,
            items: items
        )
    }
}
