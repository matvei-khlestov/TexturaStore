//
//  AppRouter+Typealiases.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import Foundation

typealias StackRouter<StackRoute: StackRoutable> = AppRouter<StackRoute, NoRoute, NoRoute>
typealias StackSheetRouter<StackRoute: StackRoutable, SheetRoute: ModalRoutable> = AppRouter<StackRoute, SheetRoute, NoRoute>
typealias StackFullScreenRouter<StackRoute: StackRoutable, FullScreenRoute: ModalRoutable> = AppRouter<StackRoute, NoRoute, FullScreenRoute>

