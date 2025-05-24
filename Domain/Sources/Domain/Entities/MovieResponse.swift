//
//  MovieResponse.swift
//  Data
//
//  Created by Ahmad Yasser on 21/05/2025.
//


import Foundation

public struct MovieResponse: Codable, Sendable {
    public let page: Int
    public let results: [Movie]
    public let totalPages: Int
    public let totalResults: Int
}

public struct Movie: Codable, Sendable {
    public let adult: Bool
    public let backdropPath: String?
    public let id: Int
    public let overview: String
    public let popularity: Double
    public let posterPath: String?
    public let releaseDate: String
    public let title: String
    public let video: Bool
    public let voteAverage: Double
    public let voteCount: Int
    public let tagline: String?
    public let revenue: Double?
    public let status: String?
}
