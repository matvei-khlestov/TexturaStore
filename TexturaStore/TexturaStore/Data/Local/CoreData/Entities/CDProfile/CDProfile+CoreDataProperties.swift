//
//  CDProfile+CoreDataProperties.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//
//

public import Foundation
public import CoreData


public typealias CDProfileCoreDataPropertiesSet = NSSet

extension CDProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProfile> {
        return NSFetchRequest<CDProfile>(entityName: "CDProfile")
    }

    @NSManaged public var userId: String?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?
    @NSManaged public var updatedAt: Date?

}

extension CDProfile : Identifiable {}
