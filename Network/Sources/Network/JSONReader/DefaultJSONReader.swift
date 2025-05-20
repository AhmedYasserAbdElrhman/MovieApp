//
//  DefaultJSONReader.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
public struct DefaultJSONReader: JSONReaderProtocol {
    /// The underlying JSON decoder with standardized configuration
    public let decoder: JSONDecoder
    
    /// Initializes a new StandardJSONReader with configured decoder
    /// - Parameter customization: Optional closure to further customize the decoder
    public init(
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
        customization: ((JSONDecoder) -> Void)? = nil
    ) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        customization?(decoder)
        self.decoder = decoder
    }
    /// Decodes JSON data into the specified type
    public func decode<T: Decodable>(from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
}
