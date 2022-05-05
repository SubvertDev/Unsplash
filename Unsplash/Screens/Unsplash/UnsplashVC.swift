//
//  UnsplashVC.swift
//  Unsplash
//
//  Created by  Subvert on 4/29/22.
//

import UIKit

protocol UnsplashViewDelegate: AnyObject {
    func applyPhotos(photos: [Unsplash])
    func scrollToTopAfterSearch()
    func showEmptyBackground(state: Bool, forQuery: String?)
    func openDetailedVC(with: Unsplash)
    func showError(_: Error)
}

final class UnsplashVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section { case main }
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Unsplash>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Unsplash>
    private lazy var dataSource = makeDataSource()
    private lazy var snapshot = Snapshot()
    
    private let itemsPerRow: CGFloat = 3
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return layout
    }()
    
    private lazy var presenter = UnsplashPresenter(with: self)
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearch()
        configureCollectionView()
        presenter.getPhotoFeed()
    }
    
    // MARK: - Private
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, search in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ReuseID.photoCell, for: indexPath) as! PhotoCell
            cell.setImage(with: search)
            cell.backgroundColor = .red
            return cell
        }
        return dataSource
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
    }
    
    private func configureSearch() {
        let searchVC = UISearchController()
        searchVC.searchBar.delegate = self
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = K.Message.searchPlaceholder
        navigationItem.searchController = searchVC
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

// MARK: - Presenter Delegate
extension UnsplashVC: UnsplashViewDelegate {
    func applyPhotos(photos: [Unsplash]) {
        snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func scrollToTopAfterSearch() {
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    func showEmptyBackground(state: Bool, forQuery searchQuery: String?) {
        let message = "Whoops! Can't find \"\(searchQuery ?? "it!")\""
        collectionView.backgroundView = state ? EmptyStateView(message: message) : nil
    }
    
    func openDetailedVC(with photo: Unsplash) {
        let detailedVC = DetailedVC(photo: photo)
        navigationController?.pushViewController(detailedVC, animated: true)
    }
    
    func showError(_ error: Error) {
        showErrorOnMainThread(error)
    }
}

// MARK: - SearchBar Delegates
extension UnsplashVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(reload(_:)),
                                               object: searchController)
        perform(#selector(reload), with: searchController, afterDelay: 0.75)
    }
    
    @objc func reload(_ searchController: UISearchController) {
        presenter.getPhotosFromSearch(in: searchController)
    }
}

extension UnsplashVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchBarCancelButtonClicked()
    }
}

// MARK: - CollectionView Delegate
extension UnsplashVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.collectionCellPressed(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath)
    }
}


// MARK: - FlowLayout Delegate
extension UnsplashVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = flowLayout.sectionInset.left * 2 + flowLayout.minimumInteritemSpacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return flowLayout.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return flowLayout.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return flowLayout.minimumInteritemSpacing
    }
}
