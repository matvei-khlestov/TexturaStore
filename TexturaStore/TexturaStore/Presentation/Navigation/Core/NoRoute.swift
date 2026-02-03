//
//  NoRoute.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import Foundation

/// Маркер “маршруты не используются”.
/// Нужен, чтобы в coordinator можно было “отключить” sheet/fullScreen и не тащить пустые enum’ы.
struct NoRoute: RouteIdentifiable {
    let id: UUID = UUID()
}
