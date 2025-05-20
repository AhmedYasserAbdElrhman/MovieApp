//
//  NetworkClient.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
public final class NetworkClient: NetworkClientProtocol {
    private let urlSession: URLSession
    private let decoder: JSONReaderProtocol
    
    public init(
        urlSessionConfiguration: URLSessionConfiguration = .default,
        decoder: JSONReaderProtocol = DefaultJSONReader()
    ) {
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
        self.decoder = decoder
    }
    
    public func performRequest<T: Decodable>(_ request: URLRequestConvertible) async throws -> T {
        do {
            let request = try request.asURLRequest()
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedData: T = try decoder.decode(from: data)
                    return decodedData
                } catch {
                    print("This Json had a decodingError: \(error)", String(data: data, encoding: .utf8) ?? "")
                    throw NetworkError.decodingError(error)
                }
            case 429:
                throw NetworkError.rateLimitExceeded
            case 400...499:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            case 500...599:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw NetworkError.unknown
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
