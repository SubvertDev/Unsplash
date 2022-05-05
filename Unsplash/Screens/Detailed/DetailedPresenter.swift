//
//  DetailedPresenter.swift
//  Unsplash
//
//  Created by  Subvert on 5/3/22.
//

import Foundation

protocol DetailedPresenterDelegate {
    func retrieveFavorites()
    func saveButtonTapped()
    func downloadStats()
}

final class DetailedPresenter {
    
    // MARK: - Properties
    unowned private let view: DetailedViewDelegate
    
    private let photo: Unsplash
    private var isFavorite = false
    
    init(view: DetailedViewDelegate, photo: Unsplash) {
        self.view = view
        self.photo = photo
    }
    
    // MARK: - Public
    func retrieveFavorites() {
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let favorites):
                self.isFavorite = false
                self.view.setFavoriteButton(state: false)
                
                for favorite in favorites {
                    if favorite.id == self.photo.id {
                        self.isFavorite = true
                        self.view.setFavoriteButton(state: true)
                        break
                    }
                }
                
            case .failure(let error):
                self.view.showError(error)
            }
        }
    }
    
    func saveButtonTapped() {
        if isFavorite {
            PersistenceManager.updateWith(favorite: photo, actionType: .remove) { [weak self] error in
                guard let self = self else { return }
                guard let error = error else {
                    self.isFavorite = false
                    self.view.setFavoriteButton(state: false)
                    return
                }
                self.view.showError(error)
            }
        } else {
            PersistenceManager.updateWith(favorite: photo, actionType: .add) { [weak self] error in
                guard let self = self else { return }
                guard let error = error else {
                    self.isFavorite = true
                    self.view.setFavoriteButton(state: true)
                    return
                }
                self.view.showError(error)
            }
        }
    }
    
    func downloadStats() {
        NetworkManager.shared.getPhotoStats(id: photo.id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let stats):
                DispatchQueue.main.async {
                    self.view.setDownloads(to: stats.downloads)
                }
                
            case .failure(let error):
                self.view.showError(error)
            }
        }
    }
}
