//
//  GetAllWatchListUseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//

public final class GetAllWatchListUseCase: UseCase {
    public typealias RequestValue = ()
    public typealias ResponseValue = [Int]
    
    private let localRepository: WatchListLocalRepositoryProtocol

    public init(localRepository: WatchListLocalRepositoryProtocol) {
        self.localRepository = localRepository
    }
    public func execute(requestValue: ()) async throws -> [Int] {
        try await localRepository.getWatchListMovies()
    }
    

    
}
