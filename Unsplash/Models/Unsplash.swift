//
//  Unsplash.swift
//  Unsplash
//
//  Created by  Subvert on 4/29/22.
//

import Foundation

// MARK: - Unsplash
struct Unsplash: Codable, Hashable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let blurHash: String?
    let urls: Urls
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, urls, user
        case createdAt = "created_at"
        case blurHash = "blur_hash"
    }
}

// MARK: - Search
struct Search: Codable, Hashable {
    let total: Int
    let totalPages: Int
    let results: [Unsplash]
    
    enum CodingKeys: String, CodingKey {
        case total, results
        case totalPages = "total_pages"
    }
}

// MARK: - User
struct User: Codable, Hashable {
    let name: String
    let location: String?
}

// MARK: - Urls
struct Urls: Codable, Hashable {
    //let raw: String
    //let full: String
    let regular: String
    let small: String
    let thumb: String
    //let smallS3: String?
}
