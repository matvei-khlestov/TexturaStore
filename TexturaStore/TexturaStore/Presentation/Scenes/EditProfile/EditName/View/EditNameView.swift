//
//  EditNameView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.02.2026.
//

import SwiftUI

/// SwiftUI-экран изменения имени пользователя.
/// Аналог `EditNameViewController`, построенный на `BaseEditFieldView`.
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
            navTitle: "Изменить имя",
            onBack: onBack,
            onFinish: onFinish
        )
    }
}
