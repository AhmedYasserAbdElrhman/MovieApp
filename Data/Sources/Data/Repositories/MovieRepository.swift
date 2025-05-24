//
//  MovieRepository.swift
//  Data
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Network
import Domain
public final class MovieRepository: MovieRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    
    public init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    public func getPopularMovies(query: GetMoviesQueryParameters) async throws -> MovieResponse {
        try await networkClient.performRequest(MoviesRoute.popular(query: query))
    }
    public func searchMovies(query: GetMoviesQueryParameters) async throws -> MovieResponse {
        try await networkClient.performRequest(MoviesRoute.search(query: query))
    }


    public func getMovieDetails(id: Int) async throws -> Movie {
        try await networkClient.performRequest(MovieDetailsRoute.details(id))
    }
    
    public func getSimilarMovies(id: Int) async throws -> MovieResponse {
        try await networkClient.performRequest(MovieDetailsRoute.similar(id))
    }
    
    public func getMovieCredits(id: Int) async throws -> MovieCredits {
        try await networkClient.performRequest(MovieDetailsRoute.credits(id))
    }
    
    
}

