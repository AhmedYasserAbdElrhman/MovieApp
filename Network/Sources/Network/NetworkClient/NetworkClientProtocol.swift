//
//  NetworkClientProtocol.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//


import Foundation

public protocol NetworkClientProtocol: Sendable {
    func performRequest<T: Decodable>(_ request: URLRequestConvertible) async throws -> T
}
