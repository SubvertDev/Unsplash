//
//  NetworkManager.swift
//  Unsplash
//
//  Created by  Subvert on 4/29/22.
//

import Foundation
import UIKit

final class NetworkManager {
    
    // MARK: - Properties
    static let shared = NetworkManager()
    private let baseURL = "https://api.unsplash.com/"
    
    enum OrderPhotosBy: String {
        case latest, popular, oldest
    }
    
    private init() {}
    
    // MARK: - Public
    func getPhotos(page: Int, orderBy: OrderPhotosBy = .latest, completion: @escaping (Result<[Unsplash], NetworkError>) -> Void) {
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.path = "/photos"
        urlComponents.queryItems = [URLQueryItem(name: "page", value: "\(page)"),
                                    URLQueryItem(name: "per_page", value: "30"),
                                    URLQueryItem(name: "order_by", value: orderBy.rawValue)]

        guard let request = createRequest(for: urlComponents.url) else {
            completion(.failure(.invaildRequest))
            return
        }
        executeRequest(request: request, completion: completion)
    }
    
    func searchForPhotos(query: String, page: Int, orderBy: OrderPhotosBy = .latest, completion: @escaping (Result<Search, NetworkError>) -> Void) {
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.path = "/search/photos"
        urlComponents.queryItems = [URLQueryItem(name: "query", value: query),
                                    URLQueryItem(name: "page", value: "\(page)"),
                                    URLQueryItem(name: "per_page", value: "30"),
                                    URLQueryItem(name: "order_by", value: orderBy.rawValue)]

        guard let request = createRequest(for: urlComponents.url) else {
            completion(.failure(.invaildRequest))
            return
        }
        executeRequest(request: request, completion: completion)
    }
        
    func getPhotoStats(id: String, completion: @escaping (Result<PhotoStats, NetworkError>) -> Void) {
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.path = "/photos/\(id)"

        guard let request = createRequest(for: urlComponents.url) else {
            completion(.failure(.invaildRequest))
            return
        }
        executeRequest(request: request, completion: completion)
    }
    
    // MARK: - Private
    private func createRequest(for url: URL?) -> URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID \(K.Network.accessKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func executeRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.unknown(message: error.localizedDescription)))
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 200...299:
                    break
                case 400:
                    completion(.failure(.invalidUrl))
                    return
                case 401:
                    completion(.failure(.unauthorized))
                    return
                case 403:
                    completion(.failure(.forbidden))
                    return
                case 404:
                    completion(.failure(.notFound))
                    return
                case 500, 503:
                    completion(.failure(.noResponse))
                    return
                default:
                    completion(.failure(.unexpectedStatusCode(code: statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.invaildData))
                return
            }
                        
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodeFailure))
            }
        }
        dataTask.resume()
    }
}

enum NetworkError: Error, LocalizedError {
    case invaildRequest
    case invalidUrl
    case noResponse
    case unauthorized
    case forbidden
    case notFound
    case unexpectedStatusCode(code: Int)
    case invaildData
    case decodeFailure
    case unknown(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invaildRequest:
            return NSLocalizedString("Failed to make a request", comment: "Invalid Request")
        case .invalidUrl:
            return NSLocalizedString("Invalid url and/or query", comment: "Invalid URL")
        case .noResponse:
            return NSLocalizedString("No response from the server", comment: "No Response")
        case .unauthorized:
            return NSLocalizedString("Unathorized access to the server", comment: "Unauthorized")
        case .forbidden:
            return NSLocalizedString("API access rate exceeded", comment: "Forbidden")
        case .notFound:
            return NSLocalizedString("Requested page was not found", comment: "Not Found")
        case .unexpectedStatusCode(let code):
            return NSLocalizedString("Unexpected status code \(code)", comment: "Unexpected Code")
        case .invaildData:
            return NSLocalizedString("Failed to read data", comment: "Invalid Data")
        case .decodeFailure:
            return NSLocalizedString("Failed to decode data", comment: "Decoding Failure")
        case .unknown(let message):
            return NSLocalizedString(message, comment: "Unknown Error")
        }
    }
}
