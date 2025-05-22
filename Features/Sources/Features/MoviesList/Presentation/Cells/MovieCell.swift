//
//  MovieCell.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//


import UIKit
import Utils
final class MovieCell: UITableViewCell {
    static let reuseID = "MovieCell"

    // MARK: - UI Components
    private let movieImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 90).isActive = true
        iv.layer.cornerRadius = 6
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 16)
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let overviewLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.numberOfLines = 3
        lbl.textColor = .darkGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let watchlistButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // New HStack for title + button
    private let titleButtonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // New VStack for the right side (titleButtonStack + overview)
    private let rightSideStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    // MARK: - Properties
    private var onWatchlistToggle: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(movieImageView)
        contentView.addSubview(rightSideStackView)
        
        // Add titleLabel and button to the horizontal stack
        titleButtonStackView.addArrangedSubview(titleLabel)
        titleButtonStackView.addArrangedSubview(watchlistButton)
        
        // Add horizontal stack and overviewLabel to the vertical stack
        rightSideStackView.addArrangedSubview(titleButtonStackView)
        rightSideStackView.addArrangedSubview(overviewLabel)
        
        NSLayoutConstraint.activate([
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            movieImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            rightSideStackView.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 12),
            rightSideStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightSideStackView.topAnchor.constraint(equalTo: movieImageView.topAnchor),
            rightSideStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            // Optionally, limit the watchlistButton size to avoid stretching
            watchlistButton.widthAnchor.constraint(equalToConstant: 24),
            watchlistButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        overviewLabel.text = nil
        movieImageView.image = nil
    }
    // MARK: - Configuration

    func configure(with movie: Movie, onWatchlistToggle: @escaping () -> Void) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        setWatchlistState(movie.isOnWatchlist)
        self.onWatchlistToggle = onWatchlistToggle
        let imagePlaceHolder = UIImage(systemName: "film")
        if let url = movie.posterURL() {
            movieImageView.setImage(with: url, placeholder: imagePlaceHolder)
        } else {
            movieImageView.image = imagePlaceHolder
        }
    }
    
    private func setWatchlistState(_ isOnWatchlist: Bool) {
        let imageName = isOnWatchlist ? "bookmark.fill" : "bookmark"
        watchlistButton.setImage(UIImage(systemName: imageName), for: .normal)
        watchlistButton.tintColor = isOnWatchlist ? .systemBlue : .systemGray
    }
    
    // MARK: - Actions
    @objc private func watchlistButtonTapped() {
        onWatchlistToggle?()
    }
}
