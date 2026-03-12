//
//  AddressInputSheetViewModelProtocol.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import Combine

/// Протокол `AddressInputSheetViewModelProtocol`
/// описывает контракт ViewModel для экрана ввода адреса.
///
/// Отвечает за:
/// - хранение и изменение полей адреса;
/// - публикацию изменений адреса и ошибок через Combine;
/// - валидацию обязательных полей.
///
/// Используется во `AddressInputSheetView`
/// для реактивного биндинга полей ввода и отображения ошибок.
protocol AddressInputSheetViewModelProtocol: AnyObject {
    
    // MARK: - Outputs
    
    /// Текущее значение адреса.
    var address: AddressInputSheetValue { get }
    
    /// Ошибка для поля города.
    var cityError: String? { get }
    
    /// Ошибка для поля улицы.
    var streetError: String? { get }
    
    /// Ошибка для поля номера дома.
    var houseError: String? { get }
    
    // MARK: - Publishers
    
    /// Паблишер изменений адреса.
    var addressPublisher: AnyPublisher<AddressInputSheetValue, Never> { get }
    
    /// Паблишер ошибки города.
    var cityErrorPublisher: AnyPublisher<String?, Never> { get }
    
    /// Паблишер ошибки улицы.
    var streetErrorPublisher: AnyPublisher<String?, Never> { get }
    
    /// Паблишер ошибки номера дома.
    var houseErrorPublisher: AnyPublisher<String?, Never> { get }
    
    // MARK: - Inputs
    
    func setCity(_ value: String)
    func setStreet(_ value: String)
    func setHouse(_ value: String)
    func setApartment(_ value: String)
    func setFloor(_ value: String)
    func setIntercomCode(_ value: String)
    
    /// Проверяет валидность введённого адреса.
    @discardableResult
    func validate() -> Bool
}
