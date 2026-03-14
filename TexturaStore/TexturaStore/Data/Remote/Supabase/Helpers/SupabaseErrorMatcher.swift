//
//  SupabaseErrorMatcher.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation

enum SupabaseErrorMatcher {
    
    static func isNoRowsError(_ error: Error) -> Bool {
        let nsError = error as NSError
        
        let text = [
            nsError.localizedDescription,
            nsError.localizedFailureReason ?? "",
            nsError.localizedRecoverySuggestion ?? "",
            String(describing: error)
        ]
        .joined(separator: " | ")
        .lowercased()
        
        return text.contains("no rows")
        || text.contains("multiple (or no) rows returned")
        || text.contains("json object requested")
        || text.contains("pgrst116")
    }
}
