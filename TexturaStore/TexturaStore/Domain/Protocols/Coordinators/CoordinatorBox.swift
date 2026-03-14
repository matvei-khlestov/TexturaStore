//
//  CoordinatorBox.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import Foundation

@MainActor
protocol CoordinatorBox: AnyObject {
    var id: UUID { get }
}
