//
//  CDCategory+CoreDataProperties.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//
//

public import Foundation
public import CoreData


public typealias CDCategoryCoreDataPropertiesSet = NSSet

extension CDCategory {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCategory> {
        return NSFetchRequest<CDCategory>(entityName: "CDCategory")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var nameRu: String?
    @NSManaged public var nameEn: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
}

extension CDCategory : Identifiable {}
