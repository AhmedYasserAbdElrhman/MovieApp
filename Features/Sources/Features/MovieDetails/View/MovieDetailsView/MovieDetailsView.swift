//
//  MovieDetailsView.swift
//  Features
//
//  Created by Ahmad Yasser on 24/05/2025.
//

import UIKit
class MovieDetailsView: UIView {
    // MARK: - Properties
    weak var delegate: MovieDetailsViewDelegate?
    
    // MARK: - UI Components
    private lazy var backdropImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.lightGray.cgColor
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.numberOfLines = 0
        return lb
    }()
    
    private lazy var watchlistButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var taglineLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.italicSystemFont(ofSize: 16)
        lb.textColor = .darkGray
        lb.numberOfLines = 0
        return lb
    }()
    
    private lazy var releaseDateLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFont(ofSize: 14)
        return lb
    }()
    
    private lazy var statusLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFont(ofSize: 14)
        return lb
    }()
    
    private lazy var revenueLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.numberOfLines = 0
        return lb
    }()
    
    private lazy var overviewLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.numberOfLines = 0
        return lb
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Setup backdrop
        addSubview(backdropImageView)
        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Setup title row
        let titleRow = UIStackView(arrangedSubviews: [titleLabel, watchlistButton])
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center
        
        // Setup info stack
        let infoStack = UIStackView(arrangedSubviews: [taglineLabel, releaseDateLabel, statusLabel, revenueLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        
        // Setup details stack
        let detailsStack = UIStackView(arrangedSubviews: [titleRow, infoStack])
        detailsStack.axis = .vertical
        detailsStack.spacing = 8
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup header stack
        let headerStack = UIStackView(arrangedSubviews: [posterImageView, detailsStack])
        headerStack.axis = .horizontal
        headerStack.spacing = 16
        headerStack.alignment = .top
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Add to view
        addSubview(headerStack)
        addSubview(overviewLabel)
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            overviewLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            overviewLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        watchlistButton.addTarget(self, action: #selector(watchlistButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func watchlistButtonTapped() {
        delegate?.didTapWatchlistButton()
    }
    
    // MARK: - Configuration
    func updateMovieDetailsUI(with movieDetails: MovieDetailsPresentationModel?) {
        guard let details = movieDetails else { return }
        
        
        // Update UI elements with movie details
        titleLabel.text = details.title
        taglineLabel.text = details.tagline
        overviewLabel.text = details.overview
        releaseDateLabel.text = "Release Date: \(details.formattedReleaseDate)"
        if let status = details.status {
            statusLabel.text = "Status: \(status)"
        }
        if let formattedRevenue = details.formattedRevenue {
            revenueLabel.text = "Revenue: \(formattedRevenue)"
        }
        
        // Load images asynchronously
        backdropImageView.setImage(with: details.backdropURL())
        posterImageView.setImage(with: details.posterURL())
    }
    func updateWatchListButtonUI(isOnWatchlist: Bool) {
        let imageName = isOnWatchlist ? "bookmark.fill" : "bookmark"
        watchlistButton.setImage(UIImage(systemName: imageName), for: .normal)
        watchlistButton.tintColor = isOnWatchlist ? .systemBlue : .systemGray
    }
}
