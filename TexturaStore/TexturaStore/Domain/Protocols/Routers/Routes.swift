//
//  Routes.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import Foundation

/// ✅ Для NavigationStack(path:): нужен только Hashable.
protocol StackRoutable: Hashable {}

/// ✅ Для sheet/fullScreenCover(item:): нужен Identifiable + Hashable.
protocol ModalRoutable: Identifiable, Hashable {}
