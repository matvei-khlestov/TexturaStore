//
//  EditNameView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import SwiftUI

struct EditNameView: View {
    
    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    private let viewModel: EditNameViewModelProtocol
    
    init(
        viewModel: EditNameViewModelProtocol,
        onBack: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onFinish = onFinish
    }
    
    var body: some View {
        BaseEditFieldView(
            viewModel: viewModel,
            fieldKind: .name,
            navTitle: L10n.Profile.EditName.title,
            onBack: onBack,
            onFinish: onFinish
        )
    }
}
