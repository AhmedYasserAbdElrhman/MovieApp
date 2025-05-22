//
//  SearchMoviesUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 21/05/2025.
//


public final class SearchMoviesUseCase: UseCase {
    typealias RequestValue = GetMoviesQueryParameters
    typealias ResponseValue = MovieResponse
    
    private let repository: MovieRepositoryProtocol
    
    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    public func execute(requestValue: GetMoviesQueryParameters) async throws -> MovieResponse {
        try await repository.searchMovies(query: requestValue)
    }

}
