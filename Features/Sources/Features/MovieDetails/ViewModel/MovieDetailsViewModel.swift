//
//  MovieDetailsViewModel.swift
//  Features
//
//  Created by Ahmad Yasser on 23/05/2025.
//


import Foundation
import Combine
import Domain
import FoundationExtensions
@MainActor
class MovieDetailsViewModel: ViewModelType {
    // MARK: - Input/Output Definition
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let watchlistTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let movieDetails: AnyPublisher<MovieDetailsPresentationModel?, Never>
        let similarMovies: AnyPublisher<[SimilarMoviePresentationModel], Never>
        let topActors: AnyPublisher<[PersonPresentationModel], Never>
        let topDirectors: AnyPublisher<[PersonPresentationModel], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<String, Never>
        let isInWatchList: AnyPublisher<Bool, Never>
    }
    // MARK: - Dependencies
    struct Dependencies {
        let movieId: Int
        let getMovieDetailsUseCase: GetMovieDetailsUseCase
        let getSimilarMoviesUseCase: GetSimilarMoviesUseCase
        let getMovieCreditsUseCase: GetMovieCreditsUseCase
        let addToWatchListUseCase: AddToWatchListUseCase
        let removeFromWatchListUseCase: RemoveFromWatchListUseCase
        let isInWatchListUseCase: IsInWatchListUseCase
        let callback: (MovieDetailsBack) -> Void
    }

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private let dependencies: Dependencies
    // MARK: - Subjects
    private let movieDetailsSubject = CurrentValueSubject<MovieDetailsPresentationModel?, Never>(nil)
    private let similarMoviesSubject = CurrentValueSubject<[SimilarMoviePresentationModel], Never>([])
    private let topActorsSubject = CurrentValueSubject<[PersonPresentationModel], Never>([])
    private let topDirectorsSubject = CurrentValueSubject<[PersonPresentationModel], Never>([])
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = PassthroughSubject<String, Never>()
    private let isInWatchListSubject = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    deinit {
        print("Deinit MovieDetailsViewModel")
    }
    // MARK: - Transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                fetchMovieDetails()
                checkMovieWatchListExistance()
            }
            .store(in: &cancellables)
        
        input.watchlistTapped
            .sink { [weak self] _ in
                guard let self else { return }
                if isInWatchListSubject.value {
                    removeFromWatchlist()
                } else {
                    addToWatchlist()
                }
            }
            .store(in: &cancellables)
        
        return Output(
            movieDetails: movieDetailsSubject.eraseToAnyPublisher(),
            similarMovies: similarMoviesSubject.eraseToAnyPublisher(),
            topActors: topActorsSubject.eraseToAnyPublisher(),
            topDirectors: topDirectorsSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher(),
            isInWatchList: isInWatchListSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Private Methods
    private func checkMovieWatchListExistance() {
        let useCase = dependencies.isInWatchListUseCase
        let movieId = dependencies.movieId
        Task {
            do {
                let response = try await useCase.execute(requestValue: movieId)
                await MainActor.run {
                    isInWatchListSubject.send(response)
                }
            } catch {
                await MainActor.run { self.handleError(errorMessage: error.localizedDescription) }
            }
        }
    }
    private func fetchMovieDetails() {
        let useCase = dependencies.getMovieDetailsUseCase
        let movieId = dependencies.movieId
        Task {
            await MainActor.run { isLoadingSubject.send(true) }
            do {
                let response = try await useCase.execute(requestValue: movieId)
                let movieDetails = MovieDetailsPresentationModel(from: response)
                await MainActor.run {
                    movieDetailsSubject.send(movieDetails)
                    isLoadingSubject.send(false)
                }
                fetchSimilarMovies(movieId: movieId)
            } catch {
                await MainActor.run { self.handleError(errorMessage: error.localizedDescription) }
            }
        }

    }
    
    private func fetchSimilarMovies(movieId: Int)  {
        let useCase = dependencies.getSimilarMoviesUseCase
        Task {
            await MainActor.run { isLoadingSubject.send(true) }
            do {
                let response = try await useCase.execute(requestValue: movieId)
                let results = response.results
                let similarMovies = results.map(SimilarMoviePresentationModel.init)
                await MainActor.run { similarMoviesSubject.send(similarMovies) }
                // After getting similar movies, fetch credits for each movie
                fetchCreditsForSimilarMovies(similarMoviesIds: similarMovies.map(\.id))
            } catch {
                await MainActor.run { self.handleError(errorMessage: error.localizedDescription) }
            }
        }
    }
    
    private func fetchCreditsForSimilarMovies(similarMoviesIds: [Int])  {
        
        let useCase = dependencies.getMovieCreditsUseCase
        Task {
            await MainActor.run { isLoadingSubject.send(true) }
            do {
                var allActors: [PersonPresentationModel] = []
                var allDirectors: [PersonPresentationModel] = []
                
                for id in similarMoviesIds {
                    let credits = try await useCase.execute(requestValue: id)
                    let actors = credits.cast.map(PersonPresentationModel.init)
                    let directors = credits.crew
                        .filter(\.isDirector)
                        .map(PersonPresentationModel.init)
                    allActors.append(contentsOf: actors)
                    allDirectors.append(contentsOf: directors)
                }
                
                // Group and sort actors by popularity
                let topActors = Array(Dictionary(grouping: allActors, by: { $0.id })
                    .values
                    .compactMap { $0.first }
                    .sorted(by: { $0.popularity > $1.popularity })
                    .prefix(5))
                
                // Group and sort directors by popularity
                let topDirectors = Array(Dictionary(grouping: allDirectors, by: { $0.id })
                    .values
                    .compactMap { $0.first }
                    .sorted(by: { $0.popularity > $1.popularity })
                    .prefix(5))
                
                await MainActor.run {
                    isLoadingSubject.send(false)
                    topActorsSubject.send(topActors)
                    topDirectorsSubject.send(topDirectors)
                }
            } catch {
                await MainActor.run { self.handleError(errorMessage: error.localizedDescription) }
            }
        }
    }
    
    private func addToWatchlist()  {
        let useCase = dependencies.addToWatchListUseCase
        let movieId = dependencies.movieId
        Task {
            do {
                try await useCase.execute(requestValue: movieId)
                await MainActor.run {
                    // Add to local cache
                    isInWatchListSubject.send(true)
                    dependencies.callback(.didAddToWatchlist(movieId))
                }
                
            } catch {
                await MainActor.run { self.handleError(errorMessage: error.coreDataFriendlyMessage) }
            }
        }
    }
    private func removeFromWatchlist()  {
        let useCase = dependencies.removeFromWatchListUseCase
        let movieId = dependencies.movieId
        Task {
            do {
                try await useCase.execute(requestValue: movieId)
                await MainActor.run {
                    // Add to local cache
                    isInWatchListSubject.send(false)
                    dependencies.callback(.didRemoveFromWatchlist(movieId))
                }
                
            } catch {
                await MainActor.run { self.handleError(errorMessage: error.coreDataFriendlyMessage) }
            }
        }
    }
    @MainActor
    private func handleError(errorMessage: String) {
        self.isLoadingSubject.send(false)
        self.errorSubject.send(errorMessage)
    }
}
