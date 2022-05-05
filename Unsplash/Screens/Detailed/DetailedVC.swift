//
//  DetailedVC.swift
//  Unsplash
//
//  Created by  Subvert on 4/30/22.
//

import UIKit
import Nuke

protocol DetailedViewDelegate: AnyObject {
    func setFavoriteButton(state: Bool)
    func setDownloads(to: Int)
    func showError(_: Error)
}

final class DetailedVC: UIViewController {
    
    // MARK: - Properties
    private var myView: DetailedView { view as! DetailedView }
    private lazy var presenter = DetailedPresenter(view: self, photo: photo)
    private let photo: Unsplash
    
    // MARK: - View Lifecycle
    override func loadView() {
        view = DetailedView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBarButton()
        downloadImage()
        myView.configureLabels(with: photo)
        presenter.downloadStats()
    }
    
    init(photo: Unsplash) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.retrieveFavorites()
        configureImageViewSize()
    }
    
    // MARK: - Private
    private func configureBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: K.ImageName.star), style: .plain, target: self, action: #selector(saveButtonTapped))
    }
    
    private func configureImageViewSize() {
        let aspectRatio = Double(photo.height) / Double(photo.width)
        let heightConstant = view.bounds.width * aspectRatio
        NSLayoutConstraint.activate([
            myView.imageView.heightAnchor.constraint(equalToConstant: heightConstant)
        ])
    }
    
    @objc private func saveButtonTapped() {
        presenter.saveButtonTapped()
    }

    private func downloadImage() {
        if let imageUrl = URL(string: photo.urls.regular) {
            let placeholderImage = UIImage(blurHash: photo.blurHash, size: K.BlurSize.normal)
            var options = ImageLoadingOptions()
            options.placeholder = placeholderImage
            options.transition = .fadeIn(duration: 0.25, options: .transitionCrossDissolve)
            options.contentModes = .init(success: .scaleAspectFill, // will fit since we set size manually
                                         failure: .scaleAspectFill,
                                         placeholder: .scaleAspectFill)
            Nuke.loadImage(with: imageUrl, options: options, into: myView.imageView)
        }
    }
}

extension DetailedVC: DetailedViewDelegate {
    func setFavoriteButton(state: Bool) {
        if state {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: K.ImageName.starFill)
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: K.ImageName.star)
        }
    }
    
    func setDownloads(to number: Int) {
        myView.setDownloadLabel(to: number)
    }
    
    func showError(_ error: Error) {
        showErrorOnMainThread(error)
    }
}
