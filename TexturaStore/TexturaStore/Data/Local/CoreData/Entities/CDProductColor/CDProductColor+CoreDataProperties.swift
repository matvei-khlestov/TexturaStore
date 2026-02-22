//
//  CDProductColor+CoreDataProperties.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//
//

public import Foundation
public import CoreData

public typealias CDProductColorCoreDataPropertiesSet = NSSet

extension CDProductColor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProductColor> {
        return NSFetchRequest<CDProductColor>(entityName: "CDProductColor")
    }

    @NSManaged public var id: String?
    @NSManaged public var nameRu: String?
    @NSManaged public var nameEn: String?
    @NSManaged public var hex: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}

extension CDProductColor : Identifiable {}
