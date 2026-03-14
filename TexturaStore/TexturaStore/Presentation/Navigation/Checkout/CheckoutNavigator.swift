//
//  CheckoutNavigator.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

@MainActor
final class CheckoutNavigator: CheckoutNavigating {
    
    // MARK: - Deps
    
    private let checkoutScreenFactory: any CheckoutScreenBuilding
    private let authService: AuthServiceProtocol
    private let makeCheckoutViewModel: (String, [CartItem]) -> any CheckoutViewModelProtocol
    private let makeAddressInputSheetViewModel: (AddressInputSheetValue?) -> any AddressInputSheetViewModelProtocol
    private let makePhoneInputSheetViewModel: (String?) -> any PhoneInputSheetViewModelProtocol
    private let makeCommentInputSheetViewModel: (String?) -> any CommentInputSheetViewModelProtocol
    private let phoneFormatter: any PhoneFormattingProtocol
    
    // MARK: - Init
    
    init(
        checkoutScreenFactory: any CheckoutScreenBuilding,
        authService: AuthServiceProtocol,
        makeCheckoutViewModel: @escaping (String, [CartItem]) -> any CheckoutViewModelProtocol,
        makeAddressInputSheetViewModel: @escaping (AddressInputSheetValue?) -> any AddressInputSheetViewModelProtocol,
        makePhoneInputSheetViewModel: @escaping (String?) -> any PhoneInputSheetViewModelProtocol,
        makeCommentInputSheetViewModel: @escaping (String?) -> any CommentInputSheetViewModelProtocol,
        phoneFormatter: any PhoneFormattingProtocol
    ) {
        self.checkoutScreenFactory = checkoutScreenFactory
        self.authService = authService
        self.makeCheckoutViewModel = makeCheckoutViewModel
        self.makeAddressInputSheetViewModel = makeAddressInputSheetViewModel
        self.makePhoneInputSheetViewModel = makePhoneInputSheetViewModel
        self.makeCommentInputSheetViewModel = makeCommentInputSheetViewModel
        self.phoneFormatter = phoneFormatter
    }
    
    // MARK: - Screens
    
    func makeRoot(
        snapshotItems: [CartItem],
        onFinished: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) -> AnyView {
        let userId = authService.currentUserId ?? ""
        let viewModel = makeCheckoutViewModel(userId, snapshotItems)
        
        return checkoutScreenFactory.makeCheckoutView(
            viewModel: viewModel,
            makeAddressSheetVM: makeAddressInputSheetViewModel,
            makePhoneSheetVM: makePhoneInputSheetViewModel,
            makeCommentSheetVM: makeCommentInputSheetViewModel,
            phoneFormatter: phoneFormatter,
            onFinished: onFinished,
            onBack: onBack
        )
    }
    
    func makeDestination(
        route: CheckoutRoute,
        snapshotItems: [CartItem],
        onBack: @escaping () -> Void,
        onFinish: @escaping () -> Void,
        onViewCatalog: @escaping () -> Void
    ) -> AnyView {
        switch route {
        case .root:
            return makeRoot(
                snapshotItems: snapshotItems,
                onFinished: onFinish,
                onBack: onBack
            )
            
        case .success:
            return checkoutScreenFactory.makeOrderSuccessView(
                onViewCatalog: onViewCatalog
            )
        }
    }
}
