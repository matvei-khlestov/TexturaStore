//
//  AddressInputSheetViewModel.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import Foundation
import Combine

/// ViewModel `AddressInputSheetViewModel` для экрана ввода адреса.
///
/// Основные задачи:
/// - хранение и обновление полей адреса;
/// - валидация обязательных полей формы;
/// - управление ошибками валидации;
/// - реактивное оповещение View об изменениях состояния.
///
/// Обеспечивает реактивные обновления через Combine:
/// - `addressPublisher` — поток изменений адреса;
/// - `cityErrorPublisher`, `streetErrorPublisher`, `houseErrorPublisher` — потоки ошибок полей.
///
/// После исправления значения автоматически очищает ошибку
/// для соответствующего поля.
final class AddressInputSheetViewModel: ObservableObject, AddressInputSheetViewModelProtocol {
    
    // MARK: - State
    
    @Published private var _address: AddressInputSheetValue
    @Published private var _cityError: String? = nil
    @Published private var _streetError: String? = nil
    @Published private var _houseError: String? = nil
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(initialAddress: AddressInputSheetValue? = nil) {
        self._address = initialAddress ?? AddressInputSheetValue(
            city: "",
            street: "",
            house: "",
            apartment: "",
            floor: "",
            intercomCode: ""
        )
        
        $_address
            .dropFirst()
            .sink { [weak self] address in
                guard let self else { return }
                
                if self._cityError != nil, !address.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self._cityError = nil
                }
                
                if self._streetError != nil, !address.street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self._streetError = nil
                }
                
                if self._houseError != nil, !address.house.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self._houseError = nil
                }
            }
            .store(in: &bag)
    }
    
    // MARK: - Outputs
    
    var address: AddressInputSheetValue { _address }
    
    var cityError: String? { _cityError }
    var streetError: String? { _streetError }
    var houseError: String? { _houseError }
    
    // MARK: - Publishers
    
    var addressPublisher: AnyPublisher<AddressInputSheetValue, Never> {
        $_address.eraseToAnyPublisher()
    }
    
    var cityErrorPublisher: AnyPublisher<String?, Never> {
        $_cityError.eraseToAnyPublisher()
    }
    
    var streetErrorPublisher: AnyPublisher<String?, Never> {
        $_streetError.eraseToAnyPublisher()
    }
    
    var houseErrorPublisher: AnyPublisher<String?, Never> {
        $_houseError.eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setCity(_ value: String) {
        _address = AddressInputSheetValue(
            city: value,
            street: _address.street,
            house: _address.house,
            apartment: _address.apartment,
            floor: _address.floor,
            intercomCode: _address.intercomCode
        )
    }
    
    func setStreet(_ value: String) {
        _address = AddressInputSheetValue(
            city: _address.city,
            street: value,
            house: _address.house,
            apartment: _address.apartment,
            floor: _address.floor,
            intercomCode: _address.intercomCode
        )
    }
    
    func setHouse(_ value: String) {
        _address = AddressInputSheetValue(
            city: _address.city,
            street: _address.street,
            house: value,
            apartment: _address.apartment,
            floor: _address.floor,
            intercomCode: _address.intercomCode
        )
    }
    
    func setApartment(_ value: String) {
        _address = AddressInputSheetValue(
            city: _address.city,
            street: _address.street,
            house: _address.house,
            apartment: value,
            floor: _address.floor,
            intercomCode: _address.intercomCode
        )
    }
    
    func setFloor(_ value: String) {
        _address = AddressInputSheetValue(
            city: _address.city,
            street: _address.street,
            house: _address.house,
            apartment: _address.apartment,
            floor: value,
            intercomCode: _address.intercomCode
        )
    }
    
    func setIntercomCode(_ value: String) {
        _address = AddressInputSheetValue(
            city: _address.city,
            street: _address.street,
            house: _address.house,
            apartment: _address.apartment,
            floor: _address.floor,
            intercomCode: value
        )
    }
    
    // MARK: - Validation
    
    @discardableResult
    func validate() -> Bool {
        let trimmedCity = _address.city.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStreet = _address.street.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHouse = _address.house.trimmingCharacters(in: .whitespacesAndNewlines)
        
        _cityError = trimmedCity.isEmpty ? "Укажите город" : nil
        _streetError = trimmedStreet.isEmpty ? "Укажите улицу" : nil
        _houseError = trimmedHouse.isEmpty ? "Укажите номер дома" : nil
        
        return _cityError == nil && _streetError == nil && _houseError == nil
    }
}
