//
//  File.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import Foundation

// MARK: - Movie
public struct MovieDetails: Decodable {
    let adult: Bool
    let backdropPath: String
    let belongsToCollection: BelongsToCollection?
    let budget: Int
    let genres: [Genre]
    let homepage: String
    let id: Int
    let imdbID: String
    let originCountry: [String]
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let releaseDate: String
    let revenue: Int
    let runtime: Int
    let spokenLanguages: [SpokenLanguage]
    let status: String
    let tagline: String
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
}

// MARK: - BelongsToCollection
struct BelongsToCollection: Decodable {
    let id: Int
    let name: String
    let posterPath: String
    let backdropPath: String
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

// MARK: - ProductionCompany
struct ProductionCompany: Decodable {
    let id: Int
    let logoPath: String
    let name: String
    let originCountry: String
}

// MARK: - ProductionCountry
struct ProductionCountry: Decodable {
    /// from JSON key "iso_3166_1" → property `iso31661`
    let iso31661: String
    let name: String
}

// MARK: - SpokenLanguage
struct SpokenLanguage: Decodable {
    let englishName: String
    /// from JSON key "iso_639_1" → property `iso6391`
    let iso6391: String
    let name: String
}
