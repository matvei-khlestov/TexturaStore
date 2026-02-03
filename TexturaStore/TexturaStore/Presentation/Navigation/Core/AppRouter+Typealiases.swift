//
//  AppRouter+Typealiases.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import Foundation

typealias StackRouter<StackRoute: RouteIdentifiable> = AppRouter<StackRoute, NoRoute, NoRoute>
typealias StackSheetRouter<StackRoute: RouteIdentifiable, SheetRoute: RouteIdentifiable> = AppRouter<StackRoute, SheetRoute, NoRoute>
typealias StackFullScreenRouter<StackRoute: RouteIdentifiable, FullScreenRoute: RouteIdentifiable> = AppRouter<StackRoute, NoRoute, FullScreenRoute>

