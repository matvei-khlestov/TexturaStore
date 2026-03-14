//
//  CategoriesFRCPublisher.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 20.02.2026.
//

import CoreData
import Combine

/// Паблишер категорий на базе `NSFetchedResultsController`.
///
/// Отвечает за:
/// - построение `NSFetchRequest<CDCategory>` с учётом фильтров (`query`, `onlyActive`);
/// - первичную выборку и публикацию доменных `Category` через Combine;
/// - автообновление данных при изменениях в Core Data (делегат FRC).
///
/// Используется в:
/// - `CatalogLocalStore` / `CatalogRepository` как реактивный источник списка категорий.
///
/// Особенности Swift 6:
/// - `NSManagedObject` не является `Sendable`, поэтому между потоками/акторами переносим только `NSManagedObjectID`;
/// - маппинг `CDCategory -> Category` выполняем на `MainActor` через `existingObject(with:)`.
final class CategoriesFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    private let subject = CurrentValueSubject<[Category], Never>([])
    
    func publisher() -> AnyPublisher<[Category], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - FRC
    
    private let frc: NSFetchedResultsController<CDCategory>
    
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
    
    init(frc: NSFetchedResultsController<CDCategory>) {
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
        print("CategoriesFRCPublisher options: \(options)")
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
                    
                    let cds: [CDCategory] = objectIDs.compactMap { id in
                        (try? mainContext.existingObject(with: id)) as? CDCategory
                    }
                    
                    let items = cds.compactMap(Category.init(cd:))
#if DEBUG
                    print("CategoriesFRCPublisher initial count=\(items.count)")
#endif
                    self.subject.send(items)
                }
            } catch {
#if DEBUG
                print("❌ CategoriesFRCPublisher fetch error:", error)
#endif
                Task { @MainActor [weak self] in
                    self?.subject.send([])
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objectIDs: [NSManagedObjectID] = (controller.fetchedObjects as? [CDCategory])?.map(\.objectID) ?? []
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let mainContext = self.frc.managedObjectContext
            
            let cds: [CDCategory] = objectIDs.compactMap { id in
                (try? mainContext.existingObject(with: id)) as? CDCategory
            }
            
            let items = cds.compactMap(Category.init(cd:))
#if DEBUG
            print("CategoriesFRCPublisher didChange count=\(items.count)")
#endif
            self.subject.send(items)
        }
    }
}

// MARK: - Request builder

private extension CategoriesFRCPublisher {
    
    static func makeRequest(options: Options) -> NSFetchRequest<CDCategory> {
        let req: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        req.fetchBatchSize = 40
        req.returnsObjectsAsFaults = false
        
        var predicates: [NSPredicate] = []
        
        if options.onlyActive {
            predicates.append(NSPredicate(format: "isActive == YES"))
        }
        
        if let q = options.query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            // В TexturaStore категория хранит ru/en названия
            let byRu = NSPredicate(format: "nameRu CONTAINS[cd] %@", q)
            let byEn = NSPredicate(format: "nameEn CONTAINS[cd] %@", q)
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [byRu, byEn]))
        }
        
        if !predicates.isEmpty {
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Сортировка: сначала более свежие, затем по названию (ru -> en)
        req.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false),
            NSSortDescriptor(key: "nameRu", ascending: true),
            NSSortDescriptor(key: "nameEn", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        return req
    }
}
