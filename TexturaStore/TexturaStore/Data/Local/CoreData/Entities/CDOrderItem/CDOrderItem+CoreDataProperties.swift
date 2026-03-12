//
//  CDOrderItem+CoreDataProperties.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//
//

public import Foundation
public import CoreData

public typealias CDOrderItemCoreDataPropertiesSet = NSSet

extension CDOrderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDOrderItem> {
        return NSFetchRequest<CDOrderItem>(entityName: "CDOrderItem")
    }

    @NSManaged public var productId: String?
    @NSManaged public var brandName: String?
    @NSManaged public var title: String?
    @NSManaged public var price: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var order: CDOrder?

}

extension CDOrderItem : Identifiable {}
