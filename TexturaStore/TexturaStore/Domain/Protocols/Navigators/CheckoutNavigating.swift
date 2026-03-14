//
//  CheckoutNavigating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

@MainActor
protocol CheckoutNavigating {
    
    func makeRoot(
        snapshotItems: [CartItem],
        onFinished: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) -> AnyView
    
    func makeDestination(
        route: CheckoutRoute,
        snapshotItems: [CartItem],
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void,
        onViewCatalog: @escaping () -> Void
    ) -> AnyView
}
