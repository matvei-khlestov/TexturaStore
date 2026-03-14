//
//  CDProductReview+CoreDataProperties.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//
//

public import Foundation
public import CoreData

public typealias CDProductReviewCoreDataPropertiesSet = NSSet

extension CDProductReview {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProductReview> {
        return NSFetchRequest<CDProductReview>(entityName: "CDProductReview")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var productId: String?
    @NSManaged public var userId: String?
    @NSManaged public var rating: Int32
    @NSManaged public var comment: String?
    @NSManaged public var userName: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

extension CDProductReview : Identifiable {}
