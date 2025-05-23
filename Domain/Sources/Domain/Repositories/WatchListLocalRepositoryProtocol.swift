//
//  WatchListLocalRepositoryProtocol.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//

public protocol WatchListLocalRepositoryProtocol {
    func addMovieToWatchList(_ movieId: Int) async throws
    func removeMovieFromWatchList(_ movieId: Int) async throws
    func getWatchListMovies() async throws -> [Int]
}
