//
//  MovieListViewModel.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Combine
import Foundation
import Domain
@MainActor
final class MovieListViewModel: ViewModelType {
    private enum FetchType {
        case popular
        case search(String)
    }
    // MARK: - Input/Output Types
    struct Input {
        let searchText: AnyPublisher<String, Never>
        let selectMovie: AnyPublisher<Movie, Never>
        let toggleWatchlist: AnyPublisher<(id: Int, indexPath: IndexPath), Never>
        let viewDidLoad: AnyPublisher<Void, Never>
        let reachedBottom: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let movieSections: AnyPublisher<[MovieSection], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<Error, Never>
    }
    
    // MARK: - Dependencies
    struct Dependencies {
        let popularMoviesUseCase: GetPopularMoviesUseCase
        let searchMoviesUseCase: SearchMoviesUseCase
    }
    // MARK: - Variables
    private let dependencies: Dependencies
    private var moviesResponse: MovieResponse?
    private var isFetching = false
    // cache for first‐page popular
    private var popularFirstPageCache: MovieResponse?
    private var currentSearchQuery: String?
    // MARK: - Private Publishers
    private let movieSectionsSubject = CurrentValueSubject<[MovieSection], Never>([])
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = PassthroughSubject<Error, Never>()
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
            .sink { movie in
                print("Selected movie: \(movie.title)")
                // Handle movie selection (e.g., navigate to detail screen)
            }
            .store(in: &cancellables)
        
        // Handle watchlist toggle
        input.toggleWatchlist
            .sink { [weak self] data in
            }
            .store(in: &cancellables)
        
        // Handle initial load
        input.viewDidLoad
            .sink { [weak self] _ in
                self?.loadPopular(page: 1)
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
    
    // MARK: - Private Methods
    private func showCachedOrFetchPopular() {
        if let popularFirstPageCache, !popularFirstPageCache.results.isEmpty {
            let results = popularFirstPageCache.results
            let sections = createMovieSections(from: results.map(Movie.init))
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
                await MainActor.run { self.handleError(error: error) }
            }
        }
    }

    @MainActor
    private func handleResponse(_ response: MovieResponse, page: Int, type: FetchType) {
        self.moviesResponse = response
        let newSections = createMovieSections(from: response.results.map(Movie.init))

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
    private func handleError(error: Error) {
        self.isLoadingSubject.send(false)
        self.isFetching = false
        self.errorSubject.send(error)
    }
    private func createMovieSections(from movies: [Movie]) -> [MovieSection] {
        let groupedByYear = Dictionary(grouping: movies) { $0.releaseYear }
        let sections = groupedByYear.map { MovieSection(year: Int($0.key) ?? 0, movies: $0.value) }
        return sections.sorted(by: { $0.year > $1.year })
    }
}
extension MovieListViewModel {
    var currentPage: Int {
        guard let moviesResponse else { return 0}
        return moviesResponse.page
    }
    var lastPage: Int {
        guard let moviesResponse else { return 0}
        return moviesResponse.totalPages
    }
}
