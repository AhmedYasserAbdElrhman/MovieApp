//
//  GetMovieCreditsUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//


public final class GetMovieCreditsUseCase: UseCase {
    public typealias RequestValue = Int
    public typealias ResponseValue = MovieCredits
    
    private let repository: MovieRepositoryProtocol
    
    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    public func execute(requestValue: Int) async throws -> MovieCredits {
        try await repository.getMovieCredits(id: requestValue)
    }
}
