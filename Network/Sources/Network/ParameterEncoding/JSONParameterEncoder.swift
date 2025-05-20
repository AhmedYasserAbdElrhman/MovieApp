//
//  JSONParameterEncoder.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
struct JSONParameterEncoder: ParameterEncoding {
    func encode(_ urlRequest: inout URLRequest, with parameters: [String : Any]?) throws {
        guard let parameters = parameters else { return }
        
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw EncodingError.encodingFailed
        }
    }
}
