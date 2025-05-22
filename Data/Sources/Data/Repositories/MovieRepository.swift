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
    
//    func searchMovies(query: String, page: Int) async throws -> [Movie] {
//    }
//    
//    func getMovieDetails(id: Int) async throws -> MovieDetails {
//    }
//    
//    func getSimilarMovies(id: Int) async throws -> [Movie] {
//    }
//    
//    func getMovieCredits(id: Int) async throws -> [CastMember] {
//    }
    
    
}

