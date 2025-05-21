//
//  MoviesRoute.swift
//  Network
//
//  Created by Ahmad Yasser on 21/05/2025.
//
import Foundation
import Network
import FoundationExtensions
import Domain
enum MoviesRoute {
    case popular(query: PopularMoviesQueryParameters)
}

extension MoviesRoute: EndPointType {
    var baseURL: URL {
        MoviesDBNetworkConfig.baseURL
    }
    
    var path: String {
        switch self {
        case .popular:
            MoviesEndpointPaths.popular
        }
    }
    
    var method: Network.HTTPMethod {
        switch self {
        case .popular:
                .GET
        }
    }
    
    var headers: [String : String]? {
        MoviesDBNetworkConfig.defaultHeaders
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .popular:
            return nil
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .popular(let query):
            query.toDictionary()
        }
    }
}

extension MoviesRoute: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        let encoder: ParameterEncoding
        switch self {
        case .popular:
            encoder = URLParameterEncoder()
            try encoder.encode(&request, with: queryParameters)
        }
        return request
        
    }
}
