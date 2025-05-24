//
//  MovieListViewModel.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Combine
import Foundation
import Domain
import FoundationExtensions
@MainActor
final class MovieListViewModel: ViewModelType {
    private enum FetchType {
        case popular
        case search(String)
    }
    // MARK: - Input/Output Types
    struct Input {
        let searchText: AnyPublisher<String, Never>
        let selectMovie: AnyPublisher<(id: Int, indexPath: IndexPath), Never>
        let toggleWatchlist: AnyPublisher<(id: Int, indexPath: IndexPath), Never>
        let viewDidLoad: AnyPublisher<Void, Never>
        let reachedBottom: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let movieSections: AnyPublisher<[MovieSection], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<String, Never>
    }
    
    // MARK: - Dependencies
    struct Dependencies {
        let navigation: (MovieListNavigation) -> Void
        let popularMoviesUseCase: GetPopularMoviesUseCase
        let searchMoviesUseCase: SearchMoviesUseCase
        let addToWatchListUseCase: AddToWatchListUseCase
        let getAllWatchListUseCase: GetAllWatchListUseCase
        let removeFromWatchListUseCase: RemoveFromWatchListUseCase
    }
    // MARK: - Variables
    private let dependencies: Dependencies
    private var moviesResponse: MovieResponse?
    private var isFetching = false
    private var watchlistMovieIds = Set<Int>()
    // cache for first‐page popular
    private var popularFirstPageCache: MovieResponse?
    private var currentSearchQuery: String?
    private var currentSelectedIndexPath: IndexPath?
    // MARK: - Private Publishers
    private let movieSectionsSubject = CurrentValueSubject<[MovieSection], Never>([])
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // Handle search text changes
        input.searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                self.currentSearchQuery = query
                if query.isEmpty {
                    // show cached popular (or trigger fetch if empty)
                    self.showCachedOrFetchPopular()
                } else if query.count >= 3 {
                    self.performSearch(query)
                }
                return
            }
            .store(in: &cancellables)
        
        // Handle movie selection
        input.selectMovie
            .sink { [weak self] id, indexPath in
                guard let self else { return }
                self.currentSelectedIndexPath = indexPath
                self.dependencies.navigation(
                    .movieDetails(
                        id,
                        processMovieDetailsCallback(_:)
                    )
                )
            }
            .store(in: &cancellables)
        
        // Handle watchlist toggle
        input.toggleWatchlist
            .sink { [weak self] data in
                guard let self else { return }
                let id = data.id
                let indexPath = data.indexPath
                let movie = self.movieSectionsSubject
                    .value[indexPath.section]
                    .movies[indexPath.row]
                guard movie.id == id else { return }
                if movie.isOnWatchlist {
                    self.performRemoveFromWatchList(id, indexPath: indexPath)
                } else {
                    self.performAddToWatchList(id, indexPath: indexPath)
                    
                }
            }
            .store(in: &cancellables)
        
        // Handle initial load
        input.viewDidLoad
            .sink { [weak self] _ in
                self?.loadPopular(page: 1)
                self?.getAllWatchListMovies()
            }
            .store(in: &cancellables)
        
        // Handle reached bottom
        input.reachedBottom
            .filter { [weak self] _ in
                guard let self else { return false }
                return !self.isFetching && self.currentPage < self.lastPage
            }
            .sink { [weak self] in
                guard let self else { return }
                if let currentSearchQuery, !currentSearchQuery.isEmpty {
                    self.performSearch(currentSearchQuery, page: currentPage + 1)
                } else {
                    self.loadPopular(page: self.currentPage + 1)
                }
            }
            .store(in: &cancellables)
        return Output(
            movieSections: movieSectionsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
    private func processMovieDetailsCallback(_ callbackType: MovieDetailsBack) {
        switch callbackType {
        case .didAddToWatchlist(let movieId):
            guard let currentSelectedIndexPath else { return }
            didAddToWatchList(movieId, indexPath: currentSelectedIndexPath)
        case .didRemoveFromWatchlist(let movieId):
            guard let currentSelectedIndexPath else { return }
            didAddToWatchList(movieId, indexPath: currentSelectedIndexPath)
        }
    }
}
// MARK: - Movie Fetching Methods
extension MovieListViewModel {
    private func showCachedOrFetchPopular() {
        if let popularFirstPageCache, !popularFirstPageCache.results.isEmpty {
            let results = popularFirstPageCache.results
            let mappedResult = results.map { Movie(movieEntity: $0, isOnWatchList: watchlistMovieIds.contains($0.id))}
            let sections = createMovieSections(from: mappedResult)
            movieSectionsSubject.send(sections)
            // For making currentPage and lastPage logic works fine
            moviesResponse = popularFirstPageCache
        } else {
            loadPopular(page: 1)
        }
    }
    
    private func loadPopular(page: Int) {
        let params = GetMoviesQueryParameters(page: page)
        fetch(
            useCase: dependencies.popularMoviesUseCase,
            params: params,
            type: .popular,
            page: page
        )
    }
    
    private func performSearch(_ query: String, page: Int = 1) {
        let params = GetMoviesQueryParameters(page: page, query: query)
        fetch(
            useCase: dependencies.searchMoviesUseCase,
            params: params,
            type: .search(query),
            page: page
        )
    }
    
    private func fetch<U: UseCase>(
        useCase: U,
        params: U.RequestValue,
        type: FetchType,
        page: Int
    ) where U.RequestValue == GetMoviesQueryParameters, U.ResponseValue == MovieResponse
    {
        guard !isFetching else { return }
        isFetching = true
        
        Task {
            await MainActor.run { self.isLoadingSubject.send(true) }
            do {
                let response = try await useCase.execute(requestValue: params)
                await MainActor.run {
                    self.handleResponse(response, page: page, type: type)
                }
            } catch {
                await MainActor.run { self.handleError(errorMessage: error.localizedDescription) }
            }
        }
    }
    
    @MainActor
    private func handleResponse(_ response: MovieResponse, page: Int, type: FetchType) {
        self.moviesResponse = response
        let results = response.results
        let mappedResult = results.map {
            Movie(
                movieEntity: $0,
                isOnWatchList: watchlistMovieIds.contains($0.id)
            )
        }
        let newSections = createMovieSections(from: mappedResult)
        
        if case .popular = type, page == 1 {
            popularFirstPageCache = response
        }
        let sections: [MovieSection]
        if page == 1 {
            sections = newSections
        } else {
            sections = movieSectionsSubject.value + newSections
        }
        
        movieSectionsSubject.send(sections)
        isLoadingSubject.send(false)
        isFetching = false
    }
    
    @MainActor
    private func handleError(errorMessage: String) {
        self.isLoadingSubject.send(false)
        self.isFetching = false
        self.errorSubject.send(errorMessage)
    }
}

// MARK: - Watchlist Operations
extension MovieListViewModel {
    fileprivate func didAddToWatchList(_ movieId: Int, indexPath: IndexPath) {
        watchlistMovieIds.insert(movieId)
        movieSectionsSubject
            .value[indexPath.section]
            .movies[indexPath.row].isOnWatchlist = true
    }
    fileprivate func didRemoveFromWatchList(_ movieId: Int, indexPath: IndexPath) {
        watchlistMovieIds.remove(movieId)
        movieSectionsSubject
            .value[indexPath.section]
            .movies[indexPath.row].isOnWatchlist = false
    }
    private func performAddToWatchList(_ movieId: Int, indexPath: IndexPath) {
        let useCase = dependencies.addToWatchListUseCase
        Task {
            do {
                try await useCase.execute(requestValue: movieId)
                await MainActor.run {
                    // Add to local cache
                    didAddToWatchList(movieId, indexPath: indexPath)
                }
                
            } catch {
                print(error.coreDataFriendlyMessage)
                await MainActor.run { self.handleError(errorMessage: error.coreDataFriendlyMessage) }
            }
        }
    }
    private func performRemoveFromWatchList(_ movieId: Int, indexPath: IndexPath) {
        let useCase = dependencies.removeFromWatchListUseCase
        Task {
            do {
                try await useCase.execute(requestValue: movieId)
                await MainActor.run {
                    // Remove from local cache
                    didRemoveFromWatchList(movieId, indexPath: indexPath)
                }
                    
            } catch {
                print(error.coreDataFriendlyMessage)
                await MainActor.run { self.handleError(errorMessage: error.coreDataFriendlyMessage) }
            }
        }
    }
    
    private func getAllWatchListMovies() {
        let useCase = dependencies.getAllWatchListUseCase
        Task {
            do {
                let ids = try await useCase.execute()
                await MainActor.run {
                    let oldIds = self.watchlistMovieIds
                    self.watchlistMovieIds = Set(ids)
                    
                    // Only update if the watchlist IDs have changed
                    if oldIds != self.watchlistMovieIds {
                        self.updateMoviesWatchlistStatus()
                    }
                }
            } catch {
                print(error.coreDataFriendlyMessage)
                await MainActor.run { self.handleError(errorMessage: error.coreDataFriendlyMessage) }
            }
        }
    }
}

// MARK: - UI Update Methods
extension MovieListViewModel {
    private func updateMoviesWatchlistStatus() {
        let sections = movieSectionsSubject.value
        
        for sectionIndex in 0..<sections.count {
            let movies = sections[sectionIndex].movies
            
            for movieIndex in 0..<movies.count {
                let movieId = movies[movieIndex].id
                let currentStatus = movies[movieIndex].isOnWatchlist
                let shouldBeOnWatchlist = watchlistMovieIds.contains(movieId)
                
                // Only update if status has changed
                if currentStatus != shouldBeOnWatchlist {                    
                    // Update the model
                    movieSectionsSubject.value[sectionIndex].movies[movieIndex].isOnWatchlist = shouldBeOnWatchlist
                }
            }
        }
    }
    
    private func createMovieSections(from movies: [Movie]) -> [MovieSection] {
        let groupedByYear = Dictionary(grouping: movies) { $0.releaseYear }
        let sections = groupedByYear.map { MovieSection(year: Int($0.key), movies: $0.value) }
        return sections.sorted(by: { $0.year > $1.year })
    }
}

// MARK: - Helper Computed Properties
extension MovieListViewModel {
    var currentPage: Int {
        guard let moviesResponse else { return 0 }
        return moviesResponse.page
    }
    
    var lastPage: Int {
        guard let moviesResponse else { return 0 }
        return moviesResponse.totalPages
    }
}
