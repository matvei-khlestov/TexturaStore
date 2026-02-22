//
//  Profile.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation

struct Profile: Equatable {
    let userId: String
    var name: String
    var email: String
    var phone: String
    var updatedAt: Date
}
