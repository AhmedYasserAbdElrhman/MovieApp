//
//  WatchListLocalRepository.swift
//  Data
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import Domain
import Storage
import Foundation
import CoreData
public class WatchListLocalRepository: WatchListLocalRepositoryProtocol {
    private let storage: WatchListStack
    @MainActor
    public init(storage: WatchListStack = WatchListStack.shared) {
        self.storage = storage
    }
    public func addMovieToWatchList(_ movieId: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            storage.performBackgroundTask { context in
                let movieCoreData = Storage.Movie(context: context)
                movieCoreData.id = Int64(movieId)
                do {
                    try self.storage.save(context: context)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    public func removeMovieFromWatchList(_ movieId: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            storage.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<Storage.Movie> = Storage.Movie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
                fetchRequest.fetchLimit = 1
                
                do {
                    if let movieToDelete = try context.fetch(fetchRequest).first {
                        context.delete(movieToDelete)
                        try self.storage.save(context: context)
                        continuation.resume()
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getWatchListMovies() async throws -> [Int] {
        try await withCheckedThrowingContinuation { continuation in
            storage.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<Storage.Movie> = Storage.Movie.fetchRequest()
                
                do {
                    let movies = try context.fetch(fetchRequest)
                    let ids = movies.map(\.id).map(Int.init)
                    continuation.resume(returning: ids)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func isMovieInWatchList(_ movieId: Int) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            storage.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<Storage.Movie> = Storage.Movie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
                
                do {
                    let count = try context.count(for: fetchRequest)
                    continuation.resume(returning: count > 0)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
