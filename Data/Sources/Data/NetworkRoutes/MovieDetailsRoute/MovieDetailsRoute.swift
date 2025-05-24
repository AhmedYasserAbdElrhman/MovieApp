//
//  MovieDetailsRoute.swift
//  Data
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import Network
import Foundation
enum MovieDetailsRoute {
    case details(Int)
    case similar(Int)
    case credits(Int)
    var action: MovieDetailsAction {
        switch self {
        case .details:
            return .details
        case .similar:
            return .similar
        case .credits:
            return .credits
        }
    }
    var id: Int {
        switch self {
        case .details(let id), .similar(let id), .credits(let id):
            return id
        }
    }
}
extension MovieDetailsRoute: EndPointType {
    var baseURL: URL {
        MoviesDBNetworkConfig.baseURL
    }
    var path: String {
        String(format: MoviesEndpointPaths.details, id) + action.rawValue
    }
    
    var method: Network.HTTPMethod {
        .GET
    }
    
    var headers: [String : String]? {
        MoviesDBNetworkConfig.defaultHeaders
    }
    
    var parameters: [String : Any]? {
        nil
    }
    
    var queryParameters: [String : Any]? {
        nil
    }
}

extension MovieDetailsRoute: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        let encoder: ParameterEncoding
        encoder = URLParameterEncoder()
        try encoder.encode(&request, with: queryParameters)
        return request
    }

}
