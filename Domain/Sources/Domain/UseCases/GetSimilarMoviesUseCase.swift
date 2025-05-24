//
//  GetSimilarMoviesUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//


public final class GetSimilarMoviesUseCase: UseCase {
    public typealias RequestValue = Int
    public typealias ResponseValue = MovieResponse
    
    private let repository: MovieRepositoryProtocol
    
    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    public func execute(requestValue: Int) async throws -> MovieResponse {
        try await repository.getSimilarMovies(id: requestValue)
    }
}
