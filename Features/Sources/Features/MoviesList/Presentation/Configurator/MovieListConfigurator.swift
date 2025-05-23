//
//  MovieListConfigurator.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Domain
import Data
import UIKit
// MARK: - Configurator
public struct MovieListConfigurator {
    @MainActor
    public static func configure() -> UIViewController {
        // Setup dependencies here
        let moviesRepo: MovieRepositoryProtocol = MovieRepository()
        let popularMoviesUseCase = GetPopularMoviesUseCase(repository: moviesRepo)
        let searchMoviesUseCase = SearchMoviesUseCase(repository: moviesRepo)
        let watchListLocalRepository: WatchListLocalRepositoryProtocol = WatchListLocalRepository()
        let addToWatchListUseCase = AddToWatchListUseCase(localRepository: watchListLocalRepository)
        let getAllWatchListUseCase = GetAllWatchListUseCase(localRepository: watchListLocalRepository)
        let dependencies = MovieListViewModel.Dependencies(
            popularMoviesUseCase: popularMoviesUseCase,
            searchMoviesUseCase: searchMoviesUseCase,
            addToWatchListUseCase: addToWatchListUseCase,
            getAllWatchListUseCase: getAllWatchListUseCase
        )
        
        // Return VC with dependencies injected
        return MovieListViewController(dependencies: dependencies)
    }
}
