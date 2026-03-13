//
//  ReviewsFRCPublisher.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import CoreData
import Combine

/// Паблишер отзывов на базе `NSFetchedResultsController`.
///
/// Отвечает за:
/// - построение `NSFetchRequest<CDProductReview>` с фильтром по `productId`;
/// - первичную выборку и публикацию доменных `ProductReview` через Combine;
/// - автообновление данных при изменениях в Core Data.
///
/// Используется в:
/// - `CoreDataReviewsStore` как реактивный источник списка отзывов товара.
///
/// Особенности Swift 6:
/// - `NSManagedObject` не является `Sendable`, поэтому между потоками переносим только `NSManagedObjectID`;
/// - маппинг `CDProductReview -> ProductReview` выполняем на `MainActor`
////  через `existingObject(with:)`.
final class ReviewsFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    private let subject = CurrentValueSubject<[ProductReview], Never>([])
    
    func publisher() -> AnyPublisher<[ProductReview], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - FRC
    
    private let frc: NSFetchedResultsController<CDProductReview>
    
    // MARK: - Filters (Options)
    
    struct Options: Equatable {
        let productId: String
        
        init(productId: String) {
            self.productId = productId
        }
    }
    
    // MARK: - Designated init
    
    init(frc: NSFetchedResultsController<CDProductReview>) {
        self.frc = frc
        super.init()
        self.frc.delegate = self
        performInitialFetch(on: frc.managedObjectContext)
    }
    
    // MARK: - Convenience init
    
    init(context: NSManagedObjectContext, options: Options) {
        let request = Self.makeRequest(options: options)
        self.frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        self.frc.delegate = self
        performInitialFetch(on: context)
#if DEBUG
        print("ReviewsFRCPublisher options: \(options)")
#endif
    }
    
    convenience init(context: NSManagedObjectContext, productId: String) {
        self.init(context: context, options: .init(productId: productId))
    }
    
    deinit {
        frc.delegate = nil
    }
    
    // MARK: - Initial fetch
    
    private func performInitialFetch(on context: NSManagedObjectContext) {
        context.perform { [weak self] in
            guard let self else { return }
            
            do {
                try self.frc.performFetch()
                
                let objectIDs: [NSManagedObjectID] = (self.frc.fetchedObjects ?? []).map(\.objectID)
                
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    
                    let mainContext = self.frc.managedObjectContext
                    
                    let cds: [CDProductReview] = objectIDs.compactMap { id in
                        (try? mainContext.existingObject(with: id)) as? CDProductReview
                    }
                    
                    let items = cds.compactMap(ProductReview.init(cd:))
#if DEBUG
                    print("ReviewsFRCPublisher initial count=\(items.count)")
#endif
                    self.subject.send(items)
                }
            } catch {
#if DEBUG
                print("❌ ReviewsFRCPublisher fetch error:", error)
#endif
                Task { @MainActor [weak self] in
                    self?.subject.send([])
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objectIDs: [NSManagedObjectID] = (controller.fetchedObjects as? [CDProductReview])?.map(\.objectID) ?? []
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let mainContext = self.frc.managedObjectContext
            
            let cds: [CDProductReview] = objectIDs.compactMap { id in
                (try? mainContext.existingObject(with: id)) as? CDProductReview
            }
            
            let items = cds.compactMap(ProductReview.init(cd:))
#if DEBUG
            print("ReviewsFRCPublisher didChange count=\(items.count)")
#endif
            self.subject.send(items)
        }
    }
}

// MARK: - Request builder

private extension ReviewsFRCPublisher {
    
    static func makeRequest(options: Options) -> NSFetchRequest<CDProductReview> {
        let req: NSFetchRequest<CDProductReview> = CDProductReview.fetchRequest()
        req.fetchBatchSize = 40
        req.returnsObjectsAsFaults = false
        req.predicate = NSPredicate(format: "productId == %@", options.productId)
        
        req.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "updatedAt", ascending: false),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        return req
    }
}
