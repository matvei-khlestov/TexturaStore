//
//  Container+Repositories.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 08.02.2026.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Profile Repository Factory
    
    /// Создаёт ProfileRepository под конкретного пользователя
    var makeProfileRepository: (String) -> ProfileRepository {
        { userId in
            DefaultProfileRepository(
                remote: self.profileStore(),
                local: self.profileLocalStore(),
                userId: userId
            )
        }
    }
}
