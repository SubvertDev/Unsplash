//
//  PersistenceManager.swift
//  Unsplash
//
//  Created by  Subvert on 5/1/22.
//

import Foundation

enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys { static let favorites = "favorites" }
    
    static func updateWith(favorite: Unsplash, actionType: PersistenceActionType, completed: @escaping (PersistenceError?) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(var favorites):
                switch actionType {
                case .add:
                    guard !favorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    favorites.append(favorite)
                    
                case .remove:
                    favorites.removeAll { $0.id == favorite.id }
                }
                completed(save(favorites: favorites))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveFavorites(completed: @escaping (Result<[Unsplash], PersistenceError>) -> Void) {
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decodedFavorites = try JSONDecoder().decode([Unsplash].self, from: favoritesData)
            completed(.success(decodedFavorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    private static func save(favorites: [Unsplash]) -> PersistenceError? {
        do {
            let encodedFavorites = try JSONEncoder().encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return nil
        } catch {
            return .unableToFavorite
        }
    }
}

enum PersistenceError: Error, LocalizedError {
    case unknownError
    case alreadyInFavorites
    case unableToFavorite
    
    var errorDescription: String? {
        switch self {
        case .unknownError:
            return NSLocalizedString("Unknown error in data persistence", comment: "Unknown Error")
        case .alreadyInFavorites:
            return NSLocalizedString("This item is already favorited", comment: "Already Saved")
        case .unableToFavorite:
            return NSLocalizedString("Unable to favorite this item", comment: "Unable To Favorite")
        }
    }
}
