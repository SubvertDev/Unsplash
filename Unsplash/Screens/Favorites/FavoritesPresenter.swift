//
//  FavoritesPresenter.swift
//  Unsplash
//
//  Created by  Subvert on 5/1/22.
//

import Foundation

protocol FavoritesPresenterDelegate {
    func retrieveFavorites()
    func cellTapped(at: IndexPath)
    func deleteFavorite(at: IndexPath)
}

final class FavoritesPresenter: FavoritesPresenterDelegate {
    
    // MARK: - Properties
    unowned let view: FavoritesViewDelegate!
    
    var favorites: [Unsplash] = []
    private let message = "You have no favorites yet!"
    
    init(with view: FavoritesViewDelegate) {
        self.view = view
    }
    
    // MARK: - Public
    func retrieveFavorites() {
        PersistenceManager.retrieveFavorites { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let favorites):
                self.favorites = favorites
                self.view.updateOnRetrieval(with: favorites, message: self.message)
                
            case .failure(let error):
                self.view.showError(error)
            }
        }
    }
    
    func cellTapped(at indexPath: IndexPath) {
        view.openDetailedVC(with: favorites[indexPath.row])
    }
    
    func deleteFavorite(at indexPath: IndexPath) {
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.favorites.remove(at: indexPath.row)
                self.view.updateAfterDeletion(with: self.favorites, at: indexPath)
                return
            }
            self.view.showError(error)
        }
    }
}
