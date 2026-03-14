//
//  SupabaseDecoding.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 14.03.2026.
//

import Foundation

enum SupabaseDecoding {
    
    static func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder = SupabaseDecoderFactory.makeJSONDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: data)
    }
    
    static func decodeArray<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder = SupabaseDecoderFactory.makeJSONDecoder()
    ) throws -> [T] {
        try decoder.decode([T].self, from: data)
    }
}
