//
//  AddressInputSheetView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import SwiftUI
import Combine

/// View `AddressInputSheetView` для экрана ввода адреса.
///
/// Отвечает за:
/// - отображение полей адреса;
/// - реактивный биндинг с `AddressInputSheetViewModelProtocol`;
/// - отображение ошибок валидации;
/// - сохранение результата через `onSaveAddress`.
///
/// Особенности:
/// - обязательные поля: город, улица, номер дома;
/// - необязательные поля: квартира, этаж, код домофона;
/// - сохранение происходит только после успешной валидации.
struct AddressInputSheetView: View {
    
    // MARK: - VM
    
    private let viewModel: any AddressInputSheetViewModelProtocol
    
    // MARK: - Callback
    
    var onSaveAddress: ((AddressInputSheetValue) -> Void)?
    
    // MARK: - State
    
    @State private var cityText: String = ""
    @State private var streetText: String = ""
    @State private var houseText: String = ""
    @State private var apartmentText: String = ""
    @State private var floorText: String = ""
    @State private var intercomCodeText: String = ""
    
    @State private var cityError: String?
    @State private var streetError: String?
    @State private var houseError: String?
    
    // MARK: - Env
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let buttonHeight: CGFloat = 52
            static let buttonCornerRadius: CGFloat = 16
        }
        
        enum Insets {
            static let horizontal: CGFloat = 16
            static let top: CGFloat = 20
            static let bottom: CGFloat = 20
        }
        
        enum Spacing {
            static let content: CGFloat = 16
        }
    }
    
    // MARK: - Init
    
    init(
        viewModel: any AddressInputSheetViewModelProtocol,
        onSaveAddress: ((AddressInputSheetValue) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onSaveAddress = onSaveAddress
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.Spacing.content) {
                AddressFieldView(
                    title: L10n.AddressInput.City.title,
                    placeholder: L10n.AddressInput.City.placeholder,
                    text: $cityText,
                    error: cityError,
                    keyboardType: .default,
                    onTextChanged: { value in
                        viewModel.setCity(value)
                    }
                )
                
                AddressFieldView(
                    title: L10n.AddressInput.Street.title,
                    placeholder: L10n.AddressInput.Street.placeholder,
                    text: $streetText,
                    error: streetError,
                    keyboardType: .default,
                    onTextChanged: { value in
                        viewModel.setStreet(value)
                    }
                )
                
                AddressFieldView(
                    title: L10n.AddressInput.House.title,
                    placeholder: L10n.AddressInput.House.placeholder,
                    text: $houseText,
                    error: houseError,
                    keyboardType: .default,
                    onTextChanged: { value in
                        viewModel.setHouse(value)
                    }
                )
                
                AddressFieldView(
                    title: L10n.AddressInput.Apartment.title,
                    placeholder: L10n.AddressInput.Apartment.placeholder,
                    text: $apartmentText,
                    error: nil,
                    keyboardType: .numbersAndPunctuation,
                    onTextChanged: { value in
                        viewModel.setApartment(value)
                    }
                )
                
                AddressFieldView(
                    title: L10n.AddressInput.Floor.title,
                    placeholder: L10n.AddressInput.Floor.placeholder,
                    text: $floorText,
                    error: nil,
                    keyboardType: .numbersAndPunctuation,
                    onTextChanged: { value in
                        viewModel.setFloor(value)
                    }
                )
                
                AddressFieldView(
                    title: L10n.AddressInput.Intercom.title,
                    placeholder: L10n.AddressInput.Intercom.placeholder,
                    text: $intercomCodeText,
                    error: nil,
                    keyboardType: .numbersAndPunctuation,
                    onTextChanged: { value in
                        viewModel.setIntercomCode(value)
                    }
                )
                
                Button(action: saveTapped) {
                    Text(L10n.AddressInput.save)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.Sizes.buttonHeight)
                        .background(
                            RoundedRectangle(
                                cornerRadius: Metrics.Sizes.buttonCornerRadius,
                                style: .continuous
                            )
                            .fill(Color(uiColor: .brand))
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.top, Metrics.Insets.top)
            .padding(.bottom, Metrics.Insets.bottom)
        }
        .navigationTitle(L10n.AddressInput.Navigation.title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(viewModel.addressPublisher.removeDuplicates()) { address in
            cityText = address.city
            streetText = address.street
            houseText = address.house
            apartmentText = address.apartment
            floorText = address.floor
            intercomCodeText = address.intercomCode
        }
        .onReceive(viewModel.cityErrorPublisher) { message in
            cityError = message
        }
        .onReceive(viewModel.streetErrorPublisher) { message in
            streetError = message
        }
        .onReceive(viewModel.houseErrorPublisher) { message in
            houseError = message
        }
        .onAppear {
            let address = viewModel.address
            cityText = address.city
            streetText = address.street
            houseText = address.house
            apartmentText = address.apartment
            floorText = address.floor
            intercomCodeText = address.intercomCode
        }
    }
}

// MARK: - Actions

private extension AddressInputSheetView {
    
    func saveTapped() {
        if viewModel.validate() {
            onSaveAddress?(viewModel.address)
            dismiss()
        }
    }
}
