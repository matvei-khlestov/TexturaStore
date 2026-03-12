//
//  Address.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 10.03.2026.
//

import Foundation
import CoreLocation

struct Address: Codable, Hashable {
    var street: String
    var city: String
    
    init(street: String, city: String) {
        self.street = street
        self.city = city
    }
}

