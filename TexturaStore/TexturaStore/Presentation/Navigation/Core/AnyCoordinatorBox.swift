//
//  AnyCoordinatorBox.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import Foundation

@MainActor
final class AnyCoordinatorBox<C: Coordinator>: CoordinatorBox {
    let id = UUID()
    let coordinator: C
    
    init(_ coordinator: C) {
        self.coordinator = coordinator
    }
}

@MainActor
extension Coordinator {
    func storeChild<C: Coordinator>(_ coordinator: C) {
        childCoordinators.append(AnyCoordinatorBox(coordinator))
    }
    
    @discardableResult
    func storeChildAndReturnID<C: Coordinator>(_ coordinator: C) -> UUID {
        let box = AnyCoordinatorBox(coordinator)
        childCoordinators.append(box)
        return box.id
    }
    
    func removeChild(id: UUID) {
        childCoordinators.removeAll { $0.id == id }
    }
    
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
