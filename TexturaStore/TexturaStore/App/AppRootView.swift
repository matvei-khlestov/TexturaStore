//
//  AppRootView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 31.01.2026.
//

import SwiftUI

struct AppRootView<C: AppCoordinating>: View {
    
    // MARK: - State
    
    @StateObject private var coordinator: C
    @State private var didStart: Bool = false
    
    // MARK: - Init
    
    init(coordinator: @autoclosure @escaping () -> C) {
        _coordinator = StateObject(wrappedValue: coordinator())
    }
    
    // MARK: - Body
    
    var body: some View {
        coordinator.rootView
            .onAppear {
                guard !didStart else { return }
                didStart = true
                coordinator.start()
            }
    }
}
