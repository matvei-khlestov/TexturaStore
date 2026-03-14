//
//  Coordinator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI

@MainActor
protocol Coordinator: AnyObject {
    var childCoordinators: [any CoordinatorBox] { get set }
    func start()
    func finish()
    var rootView: AnyView { get }
}

@MainActor
extension Coordinator {
    func start() { }

    func finish() {
        removeAllChildren()
    }
}
