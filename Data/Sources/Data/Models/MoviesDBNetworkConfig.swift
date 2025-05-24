//
//  MoviesDBNetworkConfig.swift
//  Data
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Foundation
struct MoviesDBNetworkConfig {
    static let imageBaseURL = "https://image.tmdb.org/t/p/"
    static let baseURL: URL = {
        guard let url = URL(string: "https://api.themoviedb.org/3") else {
            fatalError("Invalid Base URL")
        }
        return url
    }()
    
    // Not secure should be replaced with secured technique
    static let apiKey = "YOUR_API_KEY_HERE"
    
    static var defaultHeaders: [String: String] {
        return [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
