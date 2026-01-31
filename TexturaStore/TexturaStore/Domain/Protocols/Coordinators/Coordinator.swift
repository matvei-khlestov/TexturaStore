//
//  Coordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI

@MainActor
protocol Coordinator: ObservableObject {
    associatedtype Root: View

    var rootView: Root { get }
    var childCoordinators: [any CoordinatorBox] { get set }

    func start()
    func finish()
}

@MainActor
extension Coordinator {
    func start() { }

    func finish() {
        removeAllChildren()
    }
}
