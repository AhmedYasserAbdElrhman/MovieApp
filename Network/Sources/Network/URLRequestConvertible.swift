//
//  URLRequestConvertible.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
public protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}
