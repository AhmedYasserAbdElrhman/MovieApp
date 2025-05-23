//
//  Movie.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//
import Domain
import Foundation
import FoundationExtensions
struct Movie {
    // TMDb image config
    private static let imageBaseURL = "https://image.tmdb.org/t/p/"

    var releaseYear: Int {
        guard let dateStr = releaseDate,
                !dateStr.isEmpty,
                let date = DateFormatter.tmdbDateFormatter.date(from: dateStr)
        else { return 2025 }
        let year = DateFormatter.tmdbYearFormatter.string(from: date)
        return Int(year) ?? 2025
    }
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    var isOnWatchlist: Bool = false
    init(movieEntity: Domain.Movie, isOnWatchList: Bool) {
        self.id = movieEntity.id
        self.title = movieEntity.title
        self.overview = movieEntity.overview
        self.posterPath = movieEntity.posterPath
        self.releaseDate = movieEntity.releaseDate
        self.isOnWatchlist = isOnWatchList
    }
    func posterURL(for size: TMDBPosterSize = .w185) -> URL? {
        guard let path = posterPath else { return nil }
        return URL(string: Self.imageBaseURL + size.rawValue + path)
    }
}
