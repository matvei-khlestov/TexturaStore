//
//  EditPhoneView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 15.02.2026.
//

import SwiftUI

struct EditPhoneView: View {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: EditPhoneViewModelProtocol
    
    // MARK: - Init
    
    init(
        viewModel: EditPhoneViewModelProtocol,
        onBack: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onFinish = onFinish
    }
    
    // MARK: - Body
    
    var body: some View {
        BaseEditFieldView(
            viewModel: viewModel,
            fieldKind: .phone,
            navTitle: L10n.Profile.EditPhone.title,
            onBack: onBack,
            onFinish: onFinish
        )
    }
}
