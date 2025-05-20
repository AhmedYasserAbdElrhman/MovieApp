//
//  JSONReaderProtocol.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
/// Protocol defining the contract for JSON decoding operations
public protocol JSONReaderProtocol {
    /// Decodes JSON data into the inferred type
    /// - Parameter data: The JSON data to decode
    /// - Returns: A decoded instance of the inferred type
    /// - Throws: Error if decoding fails
    func decode<T: Decodable>(from data: Data) throws -> T
        
    /// Returns the underlying JSONDecoder instance
    var decoder: JSONDecoder { get }
}
