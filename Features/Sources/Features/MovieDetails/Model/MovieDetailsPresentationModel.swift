//
//  MovieDetailsPresentationModel.swift
//  Features
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import Domain
import Foundation
import Data
struct MovieDetailsPresentationModel: TMDBPosterProviding, TMDBBackdropProviding {
    let title: String
    let overview: String
    let tagline: String?
    let formattedRevenue: String?
    let formattedReleaseDate: String
    let status: String?
    let posterPath: String?
    let backdropPath: String?
    // Initialize from domain entity
    init(from entity: Domain.Movie) {
        self.title = entity.title
        self.overview = entity.overview
        self.tagline = entity.tagline
        self.posterPath = entity.posterPath
        self.backdropPath = entity.backdropPath
        // Format revenue for display
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        if let revenue = entity.revenue {
            self.formattedRevenue = formatter.string(from: NSNumber(value: revenue)) ?? "$\(revenue)"
        } else {
            self.formattedRevenue = "$0"
        }
        
        // Format date for display
        let dateFormatter = DateFormatter.tmdbDateFormatter
        if let date = dateFormatter.date(from: entity.releaseDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            self.formattedReleaseDate = displayFormatter.string(from: date)
        } else {
            self.formattedReleaseDate = entity.releaseDate
        }
        
        self.status = entity.status
    }
}



