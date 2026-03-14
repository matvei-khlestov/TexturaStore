//
//  CoreDataReviewsStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 13.03.2026.
//

import CoreData
import Combine

final class CoreDataReviewsStore: BaseCoreDataStore, ReviewsLocalStore {
    
    // MARK: - Streams cache
    
    private var reviewStreams: [String: ReviewsFRCPublisher] = [:]
    
    // MARK: - Init
    
    override init(container: NSPersistentContainer) {
        super.init(container: container)
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        bg.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Normalize
    
    private func normalized(_ productId: String) -> String {
        productId.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - ReviewsLocalStore
    
    func listen(productId: String) -> AnyPublisher<[ProductReview], Never> {
        let pid = normalized(productId)
        
        if let stream = reviewStreams[pid] {
            return stream.publisher()
        }
        
        let stream = ReviewsFRCPublisher(context: viewContext, productId: pid)
        reviewStreams[pid] = stream
        return stream.publisher()
    }
    
    func fetch(productId: String) -> [ProductReview] {
        let pid = normalized(productId)
        
        if Thread.isMainThread {
            return fetchOnMain(productId: pid)
        }
        
        var result: [ProductReview] = []
        DispatchQueue.main.sync {
            result = fetchOnMain(productId: pid)
        }
        return result
    }
    
    func add(dto: ProductReviewDTO) {
        upsert(dto)
    }
    
    func update(dto: ProductReviewDTO) {
        upsert(dto)
    }
    
    func remove(reviewId: String) {
        let rid = reviewId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        bg.perform {
            do {
                let req: NSFetchRequest<CDProductReview> = CDProductReview.fetchRequest()
                req.predicate = NSPredicate(format: "id == %@", rid)
                req.fetchLimit = 1
                
                guard let existing = try self.bg.fetch(req).first else { return }
                
                self.bg.delete(existing)
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("🗑️ CoreDataReviewsStore: removed review id=\(rid)")
            } catch {
                print("❌ CoreDataReviewsStore.remove error: \(error)")
            }
        }
    }
    
    func replace(productId: String, with dtos: [ProductReviewDTO]) {
        let pid = normalized(productId)
        
        bg.perform {
            do {
                let req: NSFetchRequest<CDProductReview> = CDProductReview.fetchRequest()
                req.predicate = NSPredicate(format: "productId == %@", pid)
                
                let existing = try self.bg.fetch(req)
                
                let pairs: [(String, CDProductReview)] = existing.compactMap { entity in
                    guard let id = entity.id else { return nil }
                    return (id, entity)
                }
                
                let existingById: [String: CDProductReview] = Dictionary(
                    uniqueKeysWithValues: pairs
                )
                
                let incomingIds = Set(dtos.map(\.id))
                
                for entity in existing where !(entity.id.map(incomingIds.contains) ?? false) {
                    self.bg.delete(entity)
                }
                
                for dto in dtos {
                    if let entity = existingById[dto.id] {
                        if !entity.matches(dto) {
                            entity.apply(dto: dto)
                        }
                    } else {
                        let entity = CDProductReview(context: self.bg)
                        entity.apply(dto: dto)
                    }
                }
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("✅ CoreDataReviewsStore: replaced reviews for productId=\(pid), count=\(dtos.count)")
            } catch {
                print("❌ CoreDataReviewsStore.replace error: \(error)")
            }
        }
    }
    
    func clear(productId: String) {
        let pid = normalized(productId)
        
        bg.perform {
            do {
                let req: NSFetchRequest<CDProductReview> = CDProductReview.fetchRequest()
                req.predicate = NSPredicate(format: "productId == %@", pid)
                
                let objects = try self.bg.fetch(req)
                objects.forEach { self.bg.delete($0) }
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("🧹 CoreDataReviewsStore: cleared reviews for productId=\(pid)")
            } catch {
                print("❌ CoreDataReviewsStore.clear error: \(error)")
            }
        }
        
        reviewStreams[pid] = nil
    }
}

// MARK: - Private helpers

private extension CoreDataReviewsStore {
    
    @MainActor
    func fetchOnMain(productId: String) -> [ProductReview] {
        let req: NSFetchRequest<CDProductReview> = CDProductReview.fetchRequest()
        req.predicate = NSPredicate(format: "productId == %@", productId)
        req.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false),
            NSSortDescriptor(key: "updatedAt", ascending: false),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        
        do {
            let objects = try viewContext.fetch(req)
            return objects.compactMap(ProductReview.init(cd:))
        } catch {
            print("❌ CoreDataReviewsStore.fetch error: \(error)")
            return []
        }
    }
    
    func upsert(_ dto: ProductReviewDTO) {
        let pid = normalized(dto.productId)
        
        bg.perform {
            do {
                let req: NSFetchRequest<CDProductReview> = CDProductReview.fetchRequest()
                req.predicate = NSPredicate(format: "id == %@", dto.id)
                req.fetchLimit = 1
                
                let existing = try self.bg.fetch(req).first
                
                if let existing, existing.matches(dto) { return }
                
                let entity = existing ?? CDProductReview(context: self.bg)
                entity.apply(dto: dto)
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("✅ CoreDataReviewsStore: saved review dto id=\(dto.id), productId=\(pid)")
            } catch {
                print("❌ CoreDataReviewsStore.upsert error: \(error)")
            }
        }
    }
}
