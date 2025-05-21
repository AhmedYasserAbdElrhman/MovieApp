//
//  NetworkError.swift
//  Network
//
//  Created by Ahmad Yasser on 20/05/2025.
//

import Foundation
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case unAuthorized
    case serverError(statusCode: Int)
    case rateLimitExceeded
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .requestFailed(let error):
            return "Network request failed with error: \(error.localizedDescription)"
        case .invalidResponse:
            return "The response from the server was invalid."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .unAuthorized:
            return "Unauthorized access. Please check API Key."
        case .serverError(let statusCode):
            return "Server returned an error with status code: \(statusCode)."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
