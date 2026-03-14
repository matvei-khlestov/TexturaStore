//
//  CheckoutScreenFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

@MainActor
final class CheckoutScreenFactory: CheckoutScreenBuilding {
    
    func makeCheckoutView(
        viewModel: any CheckoutViewModelProtocol,
        makeAddressSheetVM: @escaping (AddressInputSheetValue?) -> any AddressInputSheetViewModelProtocol,
        makePhoneSheetVM: @escaping (String?) -> any PhoneInputSheetViewModelProtocol,
        makeCommentSheetVM: @escaping (String?) -> any CommentInputSheetViewModelProtocol,
        phoneFormatter: any PhoneFormattingProtocol,
        onFinished: (() -> Void)?,
        onBack: (() -> Void)?
    ) -> AnyView {
        AnyView(
            CheckoutView(
                viewModel: viewModel,
                makeAddressSheetVM: makeAddressSheetVM,
                makePhoneSheetVM: makePhoneSheetVM,
                makeCommentSheetVM: makeCommentSheetVM,
                phoneFormatter: phoneFormatter,
                onFinished: onFinished,
                onBack: onBack
            )
        )
    }
    
    func makeOrderSuccessView(
        onViewCatalog: (() -> Void)?
    ) -> AnyView {
        AnyView(
            OrderSuccessView(
                onViewCatalog: onViewCatalog
            )
        )
    }
}
