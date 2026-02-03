//
//  PrivacyPolicyScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 03.02.2026.
//

import SwiftUI

@MainActor
protocol PrivacyPolicyScreenBuilding {
    func makePrivacyPolicyView(
        onBack: @escaping () -> Void
    ) -> AnyView
}

