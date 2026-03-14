//
//  BrandsFRCPublisher.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import CoreData
import Combine

/// Паблишер брендов на базе `NSFetchedResultsController`.
///
/// Отвечает за:
/// - построение `NSFetchRequest<CDBrand>` с учётом фильтров (`query`, `onlyActive`);
/// - первичную выборку и публикацию доменных `Brand` через Combine;
/// - автообновление данных при изменениях в Core Data (делегат FRC).
///
/// Используется в:
/// - `CatalogLocalStore` / `CatalogRepository` как реактивный источник списка брендов.
///
/// Особенности Swift 6:
/// - `NSManagedObject` не является `Sendable`, поэтому между потоками/акторами переносим только `NSManagedObjectID`;
/// - маппинг `CDBrand -> Brand` выполняем на `MainActor` через `existingObject(with:)`
///   (это избегает ошибок `Sendable` и вызова `@MainActor` инициализаторов из nonisolated-контекста).
final class BrandsFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    private let subject = CurrentValueSubject<[Brand], Never>([])
    
    func publisher() -> AnyPublisher<[Brand], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - FRC
    
    private let frc: NSFetchedResultsController<CDBrand>
    
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
    
    init(frc: NSFetchedResultsController<CDBrand>) {
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
        print("BrandsFRCPublisher options: \(options)")
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
                    
                    let cds: [CDBrand] = objectIDs.compactMap { id in
                        (try? mainContext.existingObject(with: id)) as? CDBrand
                    }
                    
                    let items = cds.compactMap(Brand.init(cd:))
#if DEBUG
                    print("BrandsFRCPublisher initial count=\(items.count)")
#endif
                    self.subject.send(items)
                }
            } catch {
#if DEBUG
                print("❌ BrandsFRCPublisher fetch error:", error)
#endif
                Task { @MainActor [weak self] in
                    self?.subject.send([])
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objectIDs: [NSManagedObjectID] = (controller.fetchedObjects as? [CDBrand])?.map(\.objectID) ?? []
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let mainContext = self.frc.managedObjectContext
            
            let cds: [CDBrand] = objectIDs.compactMap { id in
                (try? mainContext.existingObject(with: id)) as? CDBrand
            }
            
            let items = cds.compactMap(Brand.init(cd:))
#if DEBUG
            print("BrandsFRCPublisher didChange count=\(items.count)")
#endif
            self.subject.send(items)
        }
    }
}

// MARK: - Request builder

private extension BrandsFRCPublisher {
    
    static func makeRequest(options: Options) -> NSFetchRequest<CDBrand> {
        let req: NSFetchRequest<CDBrand> = CDBrand.fetchRequest()
        req.fetchBatchSize = 40
        req.returnsObjectsAsFaults = false
        
        var predicates: [NSPredicate] = []
        
        if options.onlyActive {
            predicates.append(NSPredicate(format: "isActive == YES"))
        }
        
        if let q = options.query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", q))
        }
        
        if !predicates.isEmpty {
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        req.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false),
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        return req
    }
}
