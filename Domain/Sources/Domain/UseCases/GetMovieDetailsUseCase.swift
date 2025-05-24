//
//  GetMovieDetailsUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//


public final class GetMovieDetailsUseCase: UseCase {
    public typealias RequestValue = Int
    public typealias ResponseValue = Movie
    
    private let repository: MovieRepositoryProtocol
    
    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    public func execute(requestValue: Int) async throws -> Movie {
        try await repository.getMovieDetails(id: requestValue)
    }
}
