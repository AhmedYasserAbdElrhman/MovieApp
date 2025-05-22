//
//  GetPopularMoviesUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 21/05/2025.
//


public final class GetPopularMoviesUseCase: UseCase {
    public typealias RequestValue = GetMoviesQueryParameters
    public typealias ResponseValue = MovieResponse
    
    private let repository: MovieRepositoryProtocol
    
    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(requestValue: GetMoviesQueryParameters) async throws -> MovieResponse {
        try await repository.getPopularMovies(query: requestValue)
    }
}
