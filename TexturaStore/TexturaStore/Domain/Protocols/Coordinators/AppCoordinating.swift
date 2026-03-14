//
//  AppCoordinating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 01.02.2026.
//

import SwiftUI
import Combine

@MainActor
protocol AppCoordinating: Coordinator, ObservableObject {
    var route: AppRoute { get }
    var rootView: AnyView { get }
    func showAuth()
    func showMain()
}
