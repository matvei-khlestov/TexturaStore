//
//  CheckoutScreenBuilding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

@MainActor
protocol CheckoutScreenBuilding {
    
    func makeCheckoutView(
        viewModel: any CheckoutViewModelProtocol,
        makeAddressSheetVM: @escaping (AddressInputSheetValue?) -> any AddressInputSheetViewModelProtocol,
        makePhoneSheetVM: @escaping (String?) -> any PhoneInputSheetViewModelProtocol,
        makeCommentSheetVM: @escaping (String?) -> any CommentInputSheetViewModelProtocol,
        phoneFormatter: any PhoneFormattingProtocol,
        onFinished: (() -> Void)?,
        onBack: (() -> Void)?
    ) -> AnyView
    
    func makeOrderSuccessView(
        onViewCatalog: (() -> Void)?
    ) -> AnyView
}
