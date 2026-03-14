//
//  SupabaseDecoderFactory.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation

enum SupabaseDecoderFactory {
    
    static func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            if let date = SupabaseDateParser.parse(string) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(string)"
            )
        }
        
        return decoder
    }
}
