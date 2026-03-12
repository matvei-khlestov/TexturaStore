//
//  CheckoutView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import SwiftUI
import Combine
import Kingfisher

/// View `CheckoutView` для экрана оформления заказа.
///
/// Отвечает за:
/// - отображение состава заказа и итогов;
/// - переключение способа получения (самовывоз/доставка);
/// - ввод/редактирование адреса, телефона и комментария через SwiftUI-шиты;
/// - запуск оформления заказа и маршрутизацию результата (`onFinished`, `onBack`, `onPickOnMap`);
/// - обновление сумм и доступности кнопки по данным ViewModel.
///
/// Взаимодействует с:
/// - `CheckoutViewModelProtocol` — биндинг состояния, форматирование цен, валидация и оформление;
/// - фабриками шитов: `AddressInputSheetViewModelProtocol`, `PhoneInputSheetViewModelProtocol`,
///   `CommentInputSheetViewModelProtocol`;
/// - `PhoneFormattingProtocol` — форматирование телефона в UI.
///
/// Особенности:
/// - нижняя панель с итогами и кнопкой заказа;
/// - реактивное обновление через Combine;
/// - бизнес-логика и проверка данных остаются во ViewModel/сервисах.
struct CheckoutView: View {
    
    // MARK: - Callbacks
    
    var onFinished: (() -> Void)?
    var onBack: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: any CheckoutViewModelProtocol
    private let makeAddressSheetVM: (AddressInputSheetValue?) -> any AddressInputSheetViewModelProtocol
    private let makePhoneSheetVM: (String?) -> any PhoneInputSheetViewModelProtocol
    private let makeCommentSheetVM: (String?) -> any CommentInputSheetViewModelProtocol
    private let phoneFormatter: any PhoneFormattingProtocol
    
    // MARK: - State
    
    @State private var items: [CartItem]
    @State private var deliveryMethod: CheckoutViewModel.DeliveryMethod
    @State private var deliveryAddressString: String?
    @State private var receiverPhoneDisplay: String?
    @State private var receiverPhoneE164: String?
    @State private var orderCommentText: String?
    @State private var isPlaceOrderEnabled: Bool = false
    
    @State private var activeSheet: ActiveSheet?
    @State private var alertMessage: String?
    
    // MARK: - Init
    
    init(
        viewModel: any CheckoutViewModelProtocol,
        makeAddressSheetVM: @escaping (AddressInputSheetValue?) -> any AddressInputSheetViewModelProtocol,
        makePhoneSheetVM: @escaping (String?) -> any PhoneInputSheetViewModelProtocol,
        makeCommentSheetVM: @escaping (String?) -> any CommentInputSheetViewModelProtocol,
        phoneFormatter: any PhoneFormattingProtocol,
        onFinished: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.makeAddressSheetVM = makeAddressSheetVM
        self.makePhoneSheetVM = makePhoneSheetVM
        self.makeCommentSheetVM = makeCommentSheetVM
        self.phoneFormatter = phoneFormatter
        self.onFinished = onFinished
        self.onBack = onBack
        
        _items = State(initialValue: viewModel.itemsSnapshot)
        _deliveryMethod = State(initialValue: viewModel.deliveryMethod)
        _deliveryAddressString = State(initialValue: viewModel.deliveryAddressString)
        _receiverPhoneDisplay = State(initialValue: viewModel.receiverPhoneDisplay)
        _receiverPhoneE164 = State(initialValue: viewModel.receiverPhoneE164)
        _orderCommentText = State(initialValue: viewModel.orderCommentText)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            contentList
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(L10n.Checkout.Navigation.title)
        .navigationBarTitleDisplayMode(.inline)
        .brandBackButton {
            onBack?()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomSummary
        }
        .sheet(item: $activeSheet) { sheet in
            if #available(iOS 16.0, *) {
                NavigationView {
                    sheetView(for: sheet)
                }
                .presentationDetents(detents(for: sheet))
                .presentationDragIndicator(.visible)
            } else {
                // Fallback on earlier versions
            }
        }
        .alert(
            L10n.Common.Error.title,
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        alertMessage = nil
                    }
                }
            ),
            actions: {
                Button(L10n.Common.ok, role: .cancel) { }
            },
            message: {
                Text(alertMessage ?? "")
            }
        )
        .onReceive(viewModel.deliveryMethodPublisher) { method in
            deliveryMethod = method
        }
        .onReceive(viewModel.deliveryAddressStringPublisher) { value in
            deliveryAddressString = value
        }
        .onReceive(viewModel.receiverPhoneDisplayPublisher) { value in
            receiverPhoneDisplay = value
        }
        .onReceive(viewModel.orderCommentPublisher) { value in
            orderCommentText = value
        }
        .onReceive(viewModel.itemsPublisher) { value in
            items = value
        }
        .onReceive(viewModel.isPlaceOrderEnabled) { value in
            isPlaceOrderEnabled = value
        }
    }
}

// MARK: - Content List

private extension CheckoutView {
    
    var contentList: some View {
        ScrollView {
            LazyVStack(spacing: Metrics.Spacing.sectionSpacing) {
                pickupAddressSection
                checkoutSection
                deliveryInfoSection
                paymentSection
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.top, Metrics.Spacing.contentTop)
            .padding(.bottom, Metrics.Spacing.contentBottom)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - Sections

private extension CheckoutView {
    
    var pickupAddressSection: some View {
        card {
            if isPickup {
                PickupAddressRow(address: L10n.Checkout.Pickup.Address.example)
            } else {
                VStack(spacing: 0) {
                    DeliveryAddressRow(
                        address: deliveryAddressString,
                        placeholder: L10n.Checkout.Delivery.Address.placeholder
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeSheet = .address
                    }
                    
                    ChangePhoneRow(
                        phone: receiverPhoneDisplay,
                        placeholder: L10n.Checkout.Phone.placeholder
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeSheet = .phone
                    }
                    
                    OrderCommentRow(
                        comment: orderCommentText,
                        placeholder: L10n.Checkout.Comment.placeholder
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeSheet = .comment
                    }
                }
            }
        }
    }
    
    var checkoutSection: some View {
        card {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.productId) { index, item in
                    CheckoutRow(
                        item: item,
                        priceText: viewModel.formattedPrice(item.lineTotal),
                        showsSeparator: index != items.count - 1
                    )
                }
            }
        }
    }
    
    var deliveryInfoSection: some View {
        card {
            DeliveryInfoRow(
                when: isPickup
                ? L10n.Checkout.Delivery.whenPickup
                : L10n.Checkout.Delivery.whenCourier,
                cost: L10n.Checkout.Delivery.cost
            )
        }
    }
    
    var paymentSection: some View {
        card {
            PaymentMethodRow(
                title: L10n.Checkout.Payment.title,
                method: L10n.Checkout.Payment.method
            )
        }
    }
    
    func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Metrics.Corners.sectionCard,
                    style: .continuous
                )
            )
    }
}

// MARK: - Top / Bottom

private extension CheckoutView {
    
    var topBar: some View {
        Picker("", selection: Binding(
            get: { deliveryMethod == .pickup ? 0 : 1 },
            set: { index in
                let method: CheckoutViewModel.DeliveryMethod = index == 0 ? .pickup : .delivery
                viewModel.setDeliveryMethod(method)
            }
        )) {
            Text(L10n.Checkout.Segment.pickup).tag(0)
            Text(L10n.Checkout.Segment.delivery).tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Metrics.Insets.horizontal)
        .padding(.top, Metrics.Spacing.topBarTop)
        .padding(.bottom, Metrics.Spacing.topBarBottom)
        .background(Color(uiColor: .systemBackground))
    }
    
    var bottomSummary: some View {
        VStack(spacing: Metrics.Spacing.summaryRows) {
            HStack {
                Text(L10n.Checkout.Total.title)
                    .font(Font(Metrics.Fonts.total))
                    .foregroundStyle(Color(uiColor: .label))
                
                Spacer()
                
                Text(totalText)
                    .font(Font(Metrics.Fonts.total))
                    .foregroundStyle(Color(uiColor: .label))
            }
            
            HStack {
                Text(L10n.Checkout.Delivery.title)
                    .font(Font(Metrics.Fonts.summaryTitle))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                
                Spacer()
                
                Text(L10n.Checkout.Delivery.free)
                    .font(Font(Metrics.Fonts.summaryValue))
                    .foregroundStyle(Color.green)
            }
            
            Button(action: placeTapped) {
                HStack(spacing: Metrics.Spacing.orderButtonStack) {
                    Image(systemName: Symbols.orderIcon)
                        .foregroundStyle(Color.white)
                    
                    Text(L10n.Checkout.Order.button)
                        .font(Font(Metrics.Fonts.orderButton))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    Text(totalText)
                        .font(Font(Metrics.Fonts.orderButton))
                        .foregroundStyle(Color.white)
                }
                .padding(.horizontal, Metrics.Insets.orderButtonContent.left)
                .frame(height: Metrics.Sizes.orderButtonHeight)
                .background(Color.orange)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: Metrics.Corners.orderButton,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)
            .disabled(!isPlaceOrderEnabled)
            .opacity(isPlaceOrderEnabled ? 1.0 : 0.5)
        }
        .padding(.top, Metrics.Insets.bottomContainer.top)
        .padding(.horizontal, Metrics.Insets.bottomContainer.left)
        .padding(.bottom, Metrics.Insets.bottomContainer.bottom)
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Sheets

private extension CheckoutView {
    
    @ViewBuilder
    func sheetView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .address:
            AddressInputSheetView(
                viewModel: makeAddressSheetVM(currentAddressValue()),
                onSaveAddress: { value in
                    viewModel.updateDeliveryAddress(value.fullAddress)
                }
            )
        case .phone:
            PhoneInputSheetView(
                viewModel: makePhoneSheetVM(receiverPhoneE164),
                phoneFormatter: phoneFormatter,
                onSavePhone: { phone in
                    viewModel.updateReceiverPhone(phone)
                }
            )
        case .comment:
            CommentInputSheetView(
                viewModel: makeCommentSheetVM(orderCommentText),
                onSaveComment: { comment in
                    viewModel.updateOrderComment(comment)
                }
            )
        }
    }
    
    func currentAddressValue() -> AddressInputSheetValue? {
        nil
    }
}

private extension CheckoutView {
    
    @available(iOS 16.0, *)
    func detents(for sheet: ActiveSheet) -> Set<PresentationDetent> {
        switch sheet {
        case .address:
            return [.large, .large]
        case .phone:
            return [.height(320)]
        case .comment:
            return [.height(320)]
        }
    }
}

// MARK: - Actions

private extension CheckoutView {
    
    var isPickup: Bool {
        deliveryMethod == .pickup
    }
    
    var totalText: String {
        viewModel.formattedTotalPrice(from: items)
    }
    
    func placeTapped() {
        Task {
            do {
                try await viewModel.placeOrder()
                onFinished?()
                await viewModel.clearCart()
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - ActiveSheet

private extension CheckoutView {
    
    enum ActiveSheet: Identifiable {
        case address
        case phone
        case comment
        
        var id: String {
            switch self {
            case .address: return "address"
            case .phone: return "phone"
            case .comment: return "comment"
            }
        }
    }
}

// MARK: - Shared Metrics

extension CheckoutView {
    
    enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            
            static let bottomContainer: UIEdgeInsets = .init(
                top: 12,
                left: horizontal,
                bottom: 16,
                right: horizontal
            )
            
            static let orderButtonContent: UIEdgeInsets = .init(
                top: 8,
                left: 16,
                bottom: 8,
                right: 16
            )
        }
        
        enum Spacing {
            static let topBarTop: CGFloat = 12
            static let topBarBottom: CGFloat = 8
            static let summaryRows: CGFloat = 12
            static let orderButtonStack: CGFloat = 10
            static let sectionSpacing: CGFloat = 15
            static let contentTop: CGFloat = 15
            static let contentBottom: CGFloat = 16
        }
        
        enum Sizes {
            static let orderButtonHeight: CGFloat = 52
            static let checkoutThumb: CGFloat = 110
            static let icon: CGFloat = 30
            static let pickupIcon: CGFloat = 28
            static let separatorHeight: CGFloat = 0.5
        }
        
        enum Corners {
            static let orderButton: CGFloat = 14
            static let checkoutThumb: CGFloat = 12
            static let pill: CGFloat = 10
            static let sectionCard: CGFloat = 16
        }
        
        enum Fonts {
            static let total: UIFont = .systemFont(ofSize: 17, weight: .semibold)
            static let summaryTitle: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let summaryValue: UIFont = .systemFont(ofSize: 15, weight: .medium)
            static let orderButton: UIFont = .systemFont(ofSize: 17, weight: .semibold)
            
            static let address: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let comment: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let phone: UIFont = .systemFont(ofSize: 15, weight: .regular)
            
            static let deliveryTitle: UIFont = .systemFont(ofSize: 13, weight: .medium)
            static let deliveryWhen: UIFont = .systemFont(ofSize: 17, weight: .bold)
            static let deliveryCost: UIFont = .systemFont(ofSize: 15, weight: .medium)
            
            static let paymentTitle: UIFont = .systemFont(ofSize: 15, weight: .semibold)
            static let paymentMethod: UIFont = .systemFont(ofSize: 15, weight: .regular)
            
            static let checkoutTitle: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let checkoutBrand: UIFont = .systemFont(ofSize: 12, weight: .regular)
            static let checkoutPrice: UIFont = .systemFont(ofSize: 18, weight: .bold)
            static let checkoutQuantity: UIFont = .systemFont(ofSize: 15, weight: .medium)
        }
    }
}

// MARK: - Shared Symbols

extension CheckoutView {
    
    enum Symbols {
        static let orderIcon = "shippingbox"
        static let delivery = "truck.box.fill"
        static let phone = "phone.fill"
        static let comment = "text.bubble.fill"
        static let storefront = "storefront.fill"
    }
}
