//
//  FavoriteCell.swift
//  Unsplash
//
//  Created by  Subvert on 5/1/22.
//

import UIKit
import Nuke

final class FavoriteCell: UITableViewCell {
    
    // MARK: - Properties    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Author Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func set(favorite: Unsplash) {
        let imageUrl = URL(string: favorite.urls.thumb)!
        let placeholderImage = UIImage(blurHash: favorite.blurHash, size: K.BlurSize.small)
        let options = ImageLoadingOptions(placeholder: placeholderImage)
        Nuke.loadImage(with: imageUrl, options: options, into: photoImageView)
        authorNameLabel.text = favorite.user.name
    }
    
    // MARK: - Private
    private func addSubviews() {
        addSubview(photoImageView)
        addSubview(authorNameLabel)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            photoImageView.widthAnchor.constraint(equalToConstant: 66),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor),
            
            authorNameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 8),
            authorNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
