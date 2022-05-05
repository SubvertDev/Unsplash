//
//  UnsplashPresenter.swift
//  Unsplash
//
//  Created by  Subvert on 5/1/22.
//

import UIKit

protocol UnsplashPresenterDelegate {
    func getPhotoFeed()
    func getPhotosFromSearch(in: UISearchController)
    func loadMorePhotos()
    func searchBarCancelButtonClicked()
    func collectionCellPressed(at: IndexPath)
    func willDisplayCell(at: IndexPath)
}

final class UnsplashPresenter: UnsplashPresenterDelegate {
    
    // MARK: - Properties
    unowned private let view: UnsplashViewDelegate!
    
    private var photos: [Unsplash] = []
    private var previousPhotos: [Unsplash] = []
    
    private var isEmptyState = false
    
    private var searchPage = 1
    private var searchQuery = ""
    private var hasSearch = false
    
    private var page = 1
    private var hasMorePhotos = true
    private var isLoadingMorePhotos = false
    
    init(with view: UnsplashViewDelegate) {
        self.view = view
    }
    
    // MARK: - Public
    func getPhotoFeed() {
        NetworkManager.shared.getPhotos(page: 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let photos):
                self.photos = photos
                self.previousPhotos = photos
                DispatchQueue.main.async { // we need to call it at least once from main thread
                    self.view.applyPhotos(photos: self.photos)
                }
                
            case .failure(let error):
                self.view.showError(error)
            }
        }
    }
    
    func getPhotosFromSearch(in searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchString.isEmpty, searchString != searchQuery else { return }
        
        searchPage = 1
        
        NetworkManager.shared.searchForPhotos(query: searchString, page: searchPage) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let photos):
                self.photos = photos.results
                self.hasSearch = true
                
                if self.photos.isEmpty {
                    self.isEmptyState = true
                } else {
                    self.isEmptyState = false
                    self.searchQuery = searchString
                    self.previousPhotos = self.photos
                }
                DispatchQueue.main.async {
                    self.view.scrollToTopAfterSearch()
                    self.view.showEmptyBackground(state: self.isEmptyState, forQuery: searchString)
                    self.view.applyPhotos(photos: self.photos)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view.showError(error)
                    self.view.applyPhotos(photos: self.photos)
                }
            }
        }
    }
    
    
    func loadMorePhotos() {
        guard hasMorePhotos, !isLoadingMorePhotos else { return }
        
        isLoadingMorePhotos = true
        
        if hasSearch { // load more photos for current search
            searchPage += 1
            NetworkManager.shared.searchForPhotos(query: searchQuery, page: searchPage) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let photos):
                    self.photos += photos.results
                    self.isLoadingMorePhotos = false
                    self.view.applyPhotos(photos: self.photos)
                    
                case .failure(let error):
                    self.view.showError(error)
                }
            }
        } else { // load more photos for default loading
            page += 1
            NetworkManager.shared.getPhotos(page: page) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let photos):
                    self.photos += photos
                    self.isLoadingMorePhotos = false
                    self.view.applyPhotos(photos: self.photos)
                    
                case .failure(let error):
                    self.view.showError(error)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked() {
        if isEmptyState {
            isEmptyState = false
            view.showEmptyBackground(state: false, forQuery: nil)
            photos = previousPhotos
            view.applyPhotos(photos: photos)
        }
    }
    
    func collectionCellPressed(at indexPath: IndexPath) {
        view.openDetailedVC(with: photos[indexPath.row])
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 7 && !isLoadingMorePhotos {
            loadMorePhotos()
        }
    }
}
