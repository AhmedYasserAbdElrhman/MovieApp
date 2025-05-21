//
//  YearSectionHeaderView.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//


import UIKit

class YearSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "YearSectionHeaderView"
    
    // MARK: - UI Components
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(yearLabel)
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            yearLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: yearLabel.trailingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    // MARK: - Configuration
    func configure(with year: Int) {
        yearLabel.text = "\(year)"
    }
}
