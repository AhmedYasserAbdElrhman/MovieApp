//
//  MovieRepositoryProtocol.swift
//  Domain
//
//  Created by Ahmad Yasser on 21/05/2025.
//


public protocol MovieRepositoryProtocol {
    func getPopularMovies(query: GetMoviesQueryParameters) async throws -> MovieResponse
    func searchMovies(query: GetMoviesQueryParameters) async throws -> MovieResponse
    func getMovieDetails(id: Int) async throws -> Movie
    func getSimilarMovies(id: Int) async throws -> MovieResponse
    func getMovieCredits(id: Int) async throws -> MovieCredits
}
