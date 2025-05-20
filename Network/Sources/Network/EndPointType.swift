//
//  EndPointType.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
public protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}
