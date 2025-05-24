//
//  TMDBImageURLProviders.swift
//  Data
//
//  Created by Ahmad Yasser on 24/05/2025.
//

import Foundation
public protocol TMDBPosterProviding {
    var posterPath: String? { get }
}

public protocol TMDBBackdropProviding {
    var backdropPath: String? { get }
}

public protocol TMDBProfileProviding {
    var profilePath: String? { get }
}

// Shared URL builders
extension TMDBPosterProviding {
    public func posterURL(for size: TMDBPosterSize = .w185) -> URL? {
        guard let path = posterPath else { return nil }
        return URL(string: MoviesDBNetworkConfig.imageBaseURL + size.rawValue + path)
    }
}

extension TMDBBackdropProviding {
    public func backdropURL(for size: TMDBBackdropSize = .w780) -> URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: MoviesDBNetworkConfig.imageBaseURL + size.rawValue + path)
    }
}

extension TMDBProfileProviding {
    public func profileURL(for size: TMDBProfileSize = .w185) -> URL? {
        guard let path = profilePath else { return nil }
        return URL(string: MoviesDBNetworkConfig.imageBaseURL + size.rawValue + path)
    }
}
