//
//  GetPopularMoviesUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 21/05/2025.
//


public final class GetPopularMoviesUseCase: UseCase {
    typealias RequestValue = GetMoviesQueryParameters
    typealias ResponseValue = MovieResponse
    
    private let repository: MovieRepositoryProtocol
    
    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(requestValue: PopularMoviesQueryParameters) async throws -> MovieResponse {
        try await repository.getPopularMovies(query: requestValue)
    }
}
