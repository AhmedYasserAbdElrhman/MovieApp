//
//  Encodable+Extensions.swift
//  FoundationExtensions
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Foundation
extension Encodable {
    public func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonObject as? [String: Any]
        } catch {
            print("Failed to convert to dictionary: \(error)")
            return nil
        }
    }
}
