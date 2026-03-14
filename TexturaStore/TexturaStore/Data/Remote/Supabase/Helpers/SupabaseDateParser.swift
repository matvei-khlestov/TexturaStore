//
//  SupabaseDateParser.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation

enum SupabaseDateParser {
    
    static func parse(_ string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        return iso8601Fractional.date(from: trimmed)
        ?? iso8601Plain.date(from: trimmed)
        ?? postgresFallbackSpace.date(from: trimmed)
        ?? postgresFallbackT.date(from: trimmed)
    }
}

// MARK: - Formatters

private extension SupabaseDateParser {
    
    static let iso8601Fractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static let iso8601Plain: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let postgresFallbackSpace: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssXXXXX"
        return formatter
    }()
    
    static let postgresFallbackT: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}
