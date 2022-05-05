//
//  DetailedView.swift
//  Unsplash
//
//  Created by  Subvert on 5/2/22.
//

import UIKit

final class DetailedView: UIView {
    
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 12
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 16
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let authorNameLabel: LabelWithSymbolView = {
        let label = LabelWithSymbolView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdAtLabel: LabelWithSymbolView = {
        let label = LabelWithSymbolView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: LabelWithSymbolView = {
        let label = LabelWithSymbolView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let downloadedLabel: LabelWithSymbolView = {
        let label = LabelWithSymbolView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configureLabels(with photo: Unsplash) {
        authorNameLabel.set(labelText: "Author name: \(photo.user.name)", imageName: K.ImageName.person)
        createdAtLabel.set(labelText: "Created at: \(photo.createdAt.fromIsoDateToString())", imageName: K.ImageName.calendar)
        downloadedLabel.set(labelText: "Downloaded 0 times", imageName: K.ImageName.download)
        
        if let location = photo.user.location {
            locationLabel.set(labelText: "Location: \(location)", imageName: K.ImageName.location)
        } else {
            locationLabel.removeFromSuperview()
        }
    }
    
    func setDownloadLabel(to number: Int) {
        downloadedLabel.label.text = "Downloaded \(number) times"
    }
    
    // MARK: - Private
    private func addSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(infoStackView)
        
        infoStackView.addArrangedSubview(authorNameLabel)
        infoStackView.addArrangedSubview(createdAtLabel)
        infoStackView.addArrangedSubview(locationLabel)
        infoStackView.addArrangedSubview(downloadedLabel)
        infoStackView.addArrangedSubview(UIView(frame: .zero))
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
