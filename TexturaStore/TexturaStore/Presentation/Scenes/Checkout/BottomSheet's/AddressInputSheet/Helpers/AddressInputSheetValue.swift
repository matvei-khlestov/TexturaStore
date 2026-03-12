//
//  AddressInputSheetValue.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 11.03.2026.
//

import Foundation

/// Значение адреса, введённого пользователем в шите.
///
/// Используется:
/// - как результат заполнения формы адреса;
/// - для передачи наружу через `onSaveAddress`;
/// - для последующей сборки строки доставки или сохранения в storage.
struct AddressInputSheetValue: Equatable {
    
    // MARK: - Properties
    
    let city: String
    let street: String
    let house: String
    let apartment: String
    let floor: String
    let intercomCode: String
    
    // MARK: - Helpers
    
    var fullAddress: String {
        var parts: [String] = []
        
        if !city.isEmpty {
            parts.append("\(L10n.Address.Value.City.prefix) \(city)")
        }
        
        if !street.isEmpty {
            parts.append("\(L10n.Address.Value.Street.prefix) \(street)")
        }
        
        if !house.isEmpty {
            parts.append("\(L10n.Address.Value.House.prefix) \(house)")
        }
        
        if !apartment.isEmpty {
            parts.append("\(L10n.Address.Value.Apartment.prefix) \(apartment)")
        }
        
        if !floor.isEmpty {
            parts.append("\(L10n.Address.Value.Floor.prefix) \(floor)")
        }
        
        if !intercomCode.isEmpty {
            parts.append("\(L10n.Address.Value.Intercom.prefix) \(intercomCode)")
        }
        
        return parts.joined(separator: ", ")
    }
}
