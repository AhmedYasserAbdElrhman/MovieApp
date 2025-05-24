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
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
