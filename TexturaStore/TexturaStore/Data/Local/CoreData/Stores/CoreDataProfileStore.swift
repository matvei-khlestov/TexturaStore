//
//  CoreDataProfileStore.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import CoreData
import Combine

final class CoreDataProfileStore: BaseCoreDataStore, ProfileLocalStore {
    
    // MARK: - Streams cache
    
    private var profileStreams: [String: ProfileFRCPublisher] = [:]
    
    // MARK: - Init
    
    override init(container: NSPersistentContainer) {
        super.init(container: container)
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        bg.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Normalize
    
    private func normalized(_ userId: String) -> String {
        userId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    // MARK: - ProfileLocalStore
    
    func observeProfile(userId: String) -> AnyPublisher<Profile?, Never> {
        let uid = normalized(userId)
        
        if let stream = profileStreams[uid] {
            return stream.publisher()
        }
        
        let stream = ProfileFRCPublisher(context: viewContext, userId: uid)
        profileStreams[uid] = stream
        return stream.publisher()
    }
    
    func upsertProfile(_ dto: ProfileDTO) {
        let uid = normalized(dto.userId)
        
        bg.perform {
            do {
                let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", uid)
                req.fetchLimit = 1
                
                let existing = try self.bg.fetch(req).first
                
                // Нечего писать — всё совпало
                if let existing, existing.matches(dto) { return }
                
                let entity = existing ?? CDProfile(context: self.bg)
                
                if existing == nil { entity.userId = uid }
                
                entity.apply(dto: dto)
                entity.userId = uid
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("✅ CoreDataProfileStore: saved profile dto for uid=\(uid)")
            } catch {
                print("❌ CoreDataProfileStore: save error \(error)")
            }
        }
    }
    
    // MARK: - Clear
    
    func clear(userId: String) {
        let uid = normalized(userId)
        
        bg.perform {
            do {
                let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", uid)
                let objs = try self.bg.fetch(req)
                objs.forEach { self.bg.delete($0) }
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("🧹 CoreDataProfileStore: cleared profile for uid=\(uid)")
            } catch {
                print("❌ CoreDataProfileStore.clear error: \(error)")
            }
        }
        
        profileStreams[uid] = nil
    }
}
