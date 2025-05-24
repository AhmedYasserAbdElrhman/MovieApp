//
//  MovieDetailsConfigurator.swift
//  Features
//
//  Created by Ahmad Yasser on 23/05/2025.
//
import Domain
import Data
import UIKit

// MARK: - Configurator
struct MovieDetailsConfigurator {
    @MainActor
    static func configure(
        movieId: Int,
        callback: @escaping (MovieDetailsBack) -> Void
    ) -> UIViewController {
        // Setup dependencies here
        let moviesRepo: MovieRepositoryProtocol = MovieRepository()
        let getMovieDetailsUseCase = GetMovieDetailsUseCase(repository: moviesRepo)
        let getSimilarMoviesUseCase = GetSimilarMoviesUseCase(repository: moviesRepo)
        let getMovieCreditsUseCase = GetMovieCreditsUseCase(repository: moviesRepo)
        let watchListLocalRepository: WatchListLocalRepositoryProtocol = WatchListLocalRepository()
        let addToWatchListUseCase = AddToWatchListUseCase(localRepository: watchListLocalRepository)
        let removeFromWatchListUseCase = RemoveFromWatchListUseCase(localRepository: watchListLocalRepository)
        let isInWatchListUseCase = IsInWatchListUseCase(localRepository: watchListLocalRepository)
        let dependencies = MovieDetailsViewModel.Dependencies(
            movieId: movieId,
            getMovieDetailsUseCase: getMovieDetailsUseCase,
            getSimilarMoviesUseCase: getSimilarMoviesUseCase,
            getMovieCreditsUseCase: getMovieCreditsUseCase,
            addToWatchListUseCase: addToWatchListUseCase,
            removeFromWatchListUseCase: removeFromWatchListUseCase,
            isInWatchListUseCase: isInWatchListUseCase,
            callback: callback
        )
        
        // Return VC with dependencies injected
        return MovieDetailsViewController(dependencies: dependencies)
    }
}

