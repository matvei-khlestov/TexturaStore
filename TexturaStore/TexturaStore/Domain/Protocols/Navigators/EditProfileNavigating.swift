//
//  EditProfileNavigating.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import SwiftUI

@MainActor
protocol EditProfileNavigating {
    func makeRoot(
        onEditName: @escaping () -> Void,
        onEditEmail: @escaping () -> Void,
        onEditPhone: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) -> AnyView

    func makeDestination(
        route: EditProfileRoute,
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) -> AnyView
}
