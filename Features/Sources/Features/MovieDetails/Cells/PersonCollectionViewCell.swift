//
//  PersonCollectionViewCell.swift
//  Features
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import UIKit
// MARK: - Person Collection View Cell
class PersonCollectionViewCell: UICollectionViewCell {
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            roleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            roleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            roleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with name: String, role: String, imageURL: URL?) {
        nameLabel.text = name
        roleLabel.text = role
        profileImageView.setImage(with: imageURL, placeholder: UIImage(systemName: "person.fill"))
    }
    
}
