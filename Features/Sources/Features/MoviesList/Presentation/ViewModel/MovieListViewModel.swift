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
    }
    // MARK: - Variables
    private let dependencies: Dependencies
    private var moviesResponse: MovieResponse?
    private var isFetching = false
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
            .filter { $0.count >= 3 } // Only proceed if text has at least 3 characters
            .sink { [weak self] query in
                self?.searchMovies(with: query)
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
                self?.fetchPopularMovies(page: 1)
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
                self.fetchPopularMovies(page: self.currentPage + 1)
            }
            .store(in: &cancellables)
        return Output(
            movieSections: movieSectionsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Private Methods
    private func searchMovies(with query: String) {
        isLoadingSubject.send(true)
    }
    private func fetchPopularMovies(page: Int) {
        let queryParameters = PopularMoviesQueryParameters(page: page)
        isFetching = true
        // Capture dependencies locally to avoid capturing self
        let movieUseCase = dependencies.popularMoviesUseCase
        
        Task {
            await MainActor.run {
                self.isLoadingSubject.send(true)
            }
            
            do {
                
                // Execute the use case
                let response = try await movieUseCase.execute(requestValue: queryParameters)
                
                // Switch to the main actor for UI updates
                await MainActor.run {
                    handleResponse(response: response, page: page)
                }
                
            } catch {
                // Handle errors on the main actor
                await MainActor.run {
                    self.isLoadingSubject.send(false)
                    self.isFetching = false
                    self.errorSubject.send(error)
                }
            }
        }
    }
    @MainActor
    private func handleResponse(response: MovieResponse, page: Int) {
        self.moviesResponse = response

        let newSections = createMovieSections(from: response.results.map(Movie.init))
        
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
