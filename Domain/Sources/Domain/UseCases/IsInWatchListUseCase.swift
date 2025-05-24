//
//  IsInWatchListUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 24/05/2025.
//


public final class IsInWatchListUseCase: UseCase {
    public typealias RequestValue = Int
    public typealias ResponseValue = Bool
    
    private let localRepository: WatchListLocalRepositoryProtocol
    
    public init(localRepository: WatchListLocalRepositoryProtocol) {
        self.localRepository = localRepository
    }
    
    public func execute(requestValue: Int) async throws -> Bool {
        try await localRepository.isMovieInWatchList(requestValue)
    }
}
