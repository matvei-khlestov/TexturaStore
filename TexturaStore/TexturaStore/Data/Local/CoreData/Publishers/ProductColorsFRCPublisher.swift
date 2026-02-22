//
//  ProductColorsFRCPublisher.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 21.02.2026.
//

import CoreData
import Combine

/// Паблишер цветов товаров на базе `NSFetchedResultsController`.
///
/// Отвечает за:
/// - построение `NSFetchRequest<CDProductColor>` с учётом фильтров (`query`, `onlyActive`);
/// - первичную выборку и публикацию доменных `ProductColor` через Combine;
/// - автообновление данных при изменениях в Core Data (делегат FRC).
///
/// Используется в:
/// - `CatalogLocalStore` / `CatalogRepository` как реактивный источник списка цветов товаров.
///
/// Особенности Swift 6:
/// - `NSManagedObject` не является `Sendable`, поэтому между потоками/акторами переносим только `NSManagedObjectID`;
/// - маппинг `CDProductColor -> ProductColor` выполняем на `MainActor` через `existingObject(with:)`.
final class ProductColorsFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    private let subject = CurrentValueSubject<[ProductColor], Never>([])
    
    func publisher() -> AnyPublisher<[ProductColor], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - FRC
    
    private let frc: NSFetchedResultsController<CDProductColor>
    
    // MARK: - Filters (Options)
    
    struct Options: Equatable {
        var query: String?
        var onlyActive: Bool
        
        init(
            query: String? = nil,
            onlyActive: Bool = true
        ) {
            self.query = query
            self.onlyActive = onlyActive
        }
    }
    
    // MARK: - Designated init (инъекция FRC для тестов)
    
    init(frc: NSFetchedResultsController<CDProductColor>) {
        self.frc = frc
        super.init()
        self.frc.delegate = self
        performInitialFetch(on: frc.managedObjectContext)
    }
    
    // MARK: - Convenience init (prod)
    
    init(context: NSManagedObjectContext, options: Options = .init()) {
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
        print("ProductColorsFRCPublisher options: \(options)")
#endif
    }
    
    convenience init(
        context: NSManagedObjectContext,
        query: String? = nil,
        onlyActive: Bool = true
    ) {
        self.init(context: context, options: .init(query: query, onlyActive: onlyActive))
    }
    
    deinit { frc.delegate = nil }
    
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
                    
                    let cds: [CDProductColor] = objectIDs.compactMap { id in
                        (try? mainContext.existingObject(with: id)) as? CDProductColor
                    }
                    
                    let items = cds.compactMap(ProductColor.init(cd:))
#if DEBUG
                    print("ProductColorsFRCPublisher initial count=\(items.count)")
#endif
                    self.subject.send(items)
                }
            } catch {
#if DEBUG
                print("❌ ProductColorsFRCPublisher fetch error:", error)
#endif
                Task { @MainActor [weak self] in
                    self?.subject.send([])
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objectIDs: [NSManagedObjectID] = (controller.fetchedObjects as? [CDProductColor])?.map(\.objectID) ?? []
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let mainContext = self.frc.managedObjectContext
            
            let cds: [CDProductColor] = objectIDs.compactMap { id in
                (try? mainContext.existingObject(with: id)) as? CDProductColor
            }
            
            let items = cds.compactMap(ProductColor.init(cd:))
#if DEBUG
            print("ProductColorsFRCPublisher didChange count=\(items.count)")
#endif
            self.subject.send(items)
        }
    }
}

// MARK: - Request builder

private extension ProductColorsFRCPublisher {
    
    static func makeRequest(options: Options) -> NSFetchRequest<CDProductColor> {
        let req: NSFetchRequest<CDProductColor> = CDProductColor.fetchRequest()
        req.fetchBatchSize = 40
        req.returnsObjectsAsFaults = false
        
        var predicates: [NSPredicate] = []
        
        if options.onlyActive {
            predicates.append(NSPredicate(format: "isActive == YES"))
        }
        
        if let q = options.query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            // Цвета храним с ru/en названиями + hex
            let byRu = NSPredicate(format: "nameRu CONTAINS[cd] %@", q)
            let byEn = NSPredicate(format: "nameEn CONTAINS[cd] %@", q)
            let byHex = NSPredicate(format: "hex CONTAINS[cd] %@", q)
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [byRu, byEn, byHex]))
        }
        
        if !predicates.isEmpty {
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Сортировка: сначала более свежие, затем по названиям и id
        req.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false),
            NSSortDescriptor(key: "nameRu", ascending: true),
            NSSortDescriptor(key: "nameEn", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        return req
    }
}
