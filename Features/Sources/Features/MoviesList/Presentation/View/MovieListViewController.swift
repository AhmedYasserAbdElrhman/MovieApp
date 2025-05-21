//
//  MovieListViewController.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//


import UIKit
import Combine
import Domain
import Utils
class MovieListViewController: UIViewController {
    
    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for movies..."
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.reuseID)
        tableView.register(YearSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: YearSectionHeaderView.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    private let viewModel: MovieListViewModel
    private var cancellables = Set<AnyCancellable>()
    private var movieSections: [MovieSection] = []
    
    // Publishers for user actions
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let toggleWatchlistSubject = PassthroughSubject<(id: Int, indexPath: IndexPath), Never>()
    private let selectMovieSubject = PassthroughSubject<Movie, Never>()
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    let reachedBottomSubject = PassthroughSubject<Void, Never>()
    // MARK: - Initialization
    init(dependencies: MovieListViewModel.Dependencies) {
        self.viewModel = MovieListViewModel(dependencies: dependencies)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewDidLoadSubject.send(())
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Movies"
        view.backgroundColor = .systemBackground
        
        // Set up search bar delegate
        searchBar.delegate = self
        
        // Set up table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add UI components to view hierarchy
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(searchBar)
        mainStackView.addArrangedSubview(tableView)
        view.addSubview(activityIndicator)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        // Create input for view model
        let input = MovieListViewModel.Input(
            searchText: searchTextSubject.eraseToAnyPublisher(),
            selectMovie: selectMovieSubject.eraseToAnyPublisher(),
            toggleWatchlist: toggleWatchlistSubject.eraseToAnyPublisher(),
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            reachedBottom: reachedBottomSubject.eraseToAnyPublisher()
        )
        
        // Get output from view model
        let output = viewModel.transform(input: input)
        
        // Bind outputs to UI
        output.movieSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.movieSections = sections
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        output.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return movieSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieSections[section].movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseID, for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }
        
        let movie = movieSections[indexPath.section].movies[indexPath.row]
        cell.configure(with: movie) { [weak self]  in
            self?.toggleWatchlistSubject.send((id: movie.id, indexPath: indexPath))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movieSections[indexPath.section].movies[indexPath.row]
        selectMovieSubject.send(movie)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: YearSectionHeaderView.reuseIdentifier) as? YearSectionHeaderView else {
            return nil
        }
        
        let year = movieSections[section].year
        headerView.configure(with: year)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

// MARK: - UISearchBarDelegate
extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextSubject.send(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchTextSubject.send(searchText)
        }
        searchBar.resignFirstResponder()
    }
}
// MARK: - PageableView
extension MovieListViewController: PageableView {
    var scroll: UIScrollView {
        tableView
    }
}

// MARK: - UIScrollViewDelegate
extension MovieListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didEndScrolling()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didEndScrolling()
    }
}
