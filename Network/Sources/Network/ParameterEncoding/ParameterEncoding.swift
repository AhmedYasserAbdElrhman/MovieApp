//
//  ParameterEncoding.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
public protocol ParameterEncoding {
    func encode(_ urlRequest: inout URLRequest, with parameters: [String: Any]?) throws
}

enum EncodingError: Error {
    case missingParameters
    case encodingFailed
}
