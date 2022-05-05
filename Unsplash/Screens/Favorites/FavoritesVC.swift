//
//  FavoritesVC.swift
//  Unsplash
//
//  Created by  Subvert on 4/29/22.
//

import UIKit

protocol FavoritesViewDelegate: AnyObject {
    func updateOnRetrieval(with: [Unsplash], message: String)
    func updateAfterDeletion(with: [Unsplash], at: IndexPath)
    func openDetailedVC(with: Unsplash)
    func showError(_: Error)
}

final class FavoritesVC: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var presenter = FavoritesPresenter(with: self)
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presenter.retrieveFavorites()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: K.ReuseID.favoriteCell)
    }
}

// MARK: - View Delegate
extension FavoritesVC: FavoritesViewDelegate {
    func updateOnRetrieval(with favorites: [Unsplash], message: String) {
        tableView.reloadData()
        tableView.isScrollEnabled = !favorites.isEmpty
        tableView.backgroundView = favorites.isEmpty ? EmptyStateView(message: message) : nil
    }
    
    func updateAfterDeletion(with favorites: [Unsplash], at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.isScrollEnabled = !favorites.isEmpty
        tableView.backgroundView = favorites.isEmpty ? EmptyStateView(message: K.Message.noFavorites) : nil
    }
    
    func openDetailedVC(with favorite: Unsplash) {
        let detailedVC = DetailedVC(photo: favorite)
        navigationController?.pushViewController(detailedVC, animated: true)
    }
    
    func showError(_ error: Error) {
        showErrorOnMainThread(error)
    }
}

// MARK: - TableView Delegates & DataSource
extension FavoritesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ReuseID.favoriteCell, for: indexPath) as! FavoriteCell
        cell.set(favorite: presenter.favorites[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.cellTapped(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completed in
            guard let self = self else { return }
            self.presenter.deleteFavorite(at: indexPath)
            completed(true)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
}
