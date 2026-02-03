//
//  PrivacyPolicyScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

@MainActor
final class PrivacyPolicyScreenFactory: PrivacyPolicyScreenBuilding {

    func makePrivacyPolicyView(
        onBack: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            PrivacyPolicyView(onBack: onBack)
        )
    }
}
