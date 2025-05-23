//
//  AddToWatchListUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//


public final class AddToWatchListUseCase: UseCase {
    public typealias RequestValue = Int
    public typealias ResponseValue = Void
    
    private let localRepository: WatchListLocalRepositoryProtocol

    public init(localRepository: WatchListLocalRepositoryProtocol) {
        self.localRepository = localRepository
    }

    public func execute(requestValue: Int) async throws -> Void {
        try await localRepository.addMovieToWatchList(requestValue)
    }
    
}
