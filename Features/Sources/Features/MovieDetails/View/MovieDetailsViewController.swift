//
//  MovieDetailsViewController.swift
//  Features
//
//  Created by Ahmad Yasser on 23/05/2025.
//


import UIKit
import Combine
import Domain
import Utils
class MovieDetailsViewController: UIViewController {
    // MARK: - UI Components
    // Core UI components
    private lazy var scrollView = UIScrollView()
    private lazy var contentStackView = UIStackView()
    private lazy var loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // View components
    private let movieDetailsView = MovieDetailsView()
    private let similarMoviesView = SimilarMoviesView()
    private let castView = CastView()
    private let directorsView = DirectorsView()
    // MARK: - Publishers
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let watchlistTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Properties
    private let viewModel: MovieDetailsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(dependencies: MovieDetailsViewModel.Dependencies) {
        self.viewModel = MovieDetailsViewModel(dependencies: dependencies)
        super.init(nibName: nil, bundle: nil)
    }
    deinit {
        print("Deinit MovieDetailsViewController")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewDidLoadSubject.send()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupLoadingIndicator()
        setupStackView()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupStackView() {
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        addComponentsToStackView()
    }
    
    private func addComponentsToStackView() {
        contentStackView.addArrangedSubview(movieDetailsView)
        contentStackView.addArrangedSubview(similarMoviesView)
        contentStackView.addArrangedSubview(castView)
        contentStackView.addArrangedSubview(directorsView)
        
        // Set delegates and targets
        movieDetailsView.delegate = self
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        let input = MovieDetailsViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            watchlistTapped: watchlistTappedPublisher.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        // Bind movie details
        output.movieDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movieDetails in
                self?.movieDetailsView.updateMovieDetailsUI(with: movieDetails)
            }
            .store(in: &cancellables)
        
        // Bind similar movies
        output.similarMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.similarMoviesView.configure(with: movies)
            }
            .store(in: &cancellables)
        
        // Bind cast
        output.topActors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] actors in
                self?.castView.configure(with: actors)
            }
            .store(in: &cancellables)
        
        // Bind directors
        output.topDirectors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] directors in
                self?.directorsView.configure(with: directors)
            }
            .store(in: &cancellables)
        
        // Bind loading state
        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // Bind errors
        output.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert(title: "Error", message: error)
            }
            .store(in: &cancellables)
        
        // Bind add to watchlist success
        output.isInWatchList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOnWatchlist in
                guard let self = self else { return }
                self.movieDetailsView.updateWatchListButtonUI(isOnWatchlist: isOnWatchlist)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

// MARK: - MovieDetailsViewDelegate
extension MovieDetailsViewController: MovieDetailsViewDelegate {
    func didTapWatchlistButton() {
        watchlistTappedPublisher.send()
    }
    
    
}
