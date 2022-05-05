//
//  Constants.swift
//  Unsplash
//
//  Created by  Subvert on 5/1/22.
//

import UIKit

struct K {
    
    struct Network {
        static let accessKey = ""
    }
    
    struct ReuseID {
        static let photoCell = "PhotoCell"
        static let favoriteCell = "FavoriteCell"
    }
    
    struct ImageName {
        static let star = "star"
        static let starFill = "star.fill"
        static let person = "person"
        static let calendar = "calendar.badge.clock"
        static let location = "mappin.and.ellipse"
        static let download = "icloud.and.arrow.down"
        static let questionMark = "questionmark.circle"
    }
    
    struct Message {
        static let noFavorites = "You have no favorites yet!"
        static let searchPlaceholder = "Search for an image"
    }
    
    struct BlurSize {
    /// Don *not* use size more than ~20 for collection cells or it will cause big lags when scrolling
        static let small = CGSize(width: 16, height: 16)
        static let normal = CGSize(width: 32, height: 32)
    }
}
