//
//  MovieRepositoryProtocol.swift
//  Domain
//
//  Created by Ahmad Yasser on 21/05/2025.
//


public protocol MovieRepositoryProtocol {
    func getPopularMovies(query: GetMoviesQueryParameters) async throws -> MovieResponse
    func searchMovies(query: GetMoviesQueryParameters) async throws -> MovieResponse
}
