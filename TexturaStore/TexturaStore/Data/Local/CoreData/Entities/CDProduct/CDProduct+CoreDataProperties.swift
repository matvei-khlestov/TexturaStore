//
//  CDProduct+CoreDataProperties.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//
//

public import Foundation
public import CoreData

public typealias CDProductCoreDataPropertiesSet = NSSet

extension CDProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProduct> {
        return NSFetchRequest<CDProduct>(entityName: "CDProduct")
    }

    @NSManaged public var id: String?
    @NSManaged public var categoryId: String?
    @NSManaged public var brandId: String?
    @NSManaged public var colorId: String?
    @NSManaged public var price: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var nameRu: String?
    @NSManaged public var nameEn: String?
    @NSManaged public var descriptionRu: String?
    @NSManaged public var descriptionEn: String?
    @NSManaged public var nameLowerRu: String?
    @NSManaged public var nameLowerEn: String?
    @NSManaged public var ratingAvg: Double
    @NSManaged public var ratingCount: Int32
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var categoryIsActive: Bool

}

extension CDProduct : Identifiable {}
