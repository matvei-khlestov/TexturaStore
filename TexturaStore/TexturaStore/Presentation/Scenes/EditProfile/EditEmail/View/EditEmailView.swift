//
//  EditEmailView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import SwiftUI

struct EditEmailView: View {
    
    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    private let viewModel: EditEmailViewModelProtocol
    
    init(
        viewModel: EditEmailViewModelProtocol,
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
            fieldKind: .email,
            navTitle: L10n.Profile.EditEmail.title,
            onBack: onBack,
            onFinish: onFinish
        )
    }
}
