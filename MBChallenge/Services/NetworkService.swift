//
//  NetworkService.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import Foundation
import Combine

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        }
    }
}

class NetworkService {
    private let baseURL: String
    private let apiKey: String
    
    init() {
        self.baseURL = Bundle.main.guardianAPIBaseURL
        self.apiKey = Bundle.main.guardianAPIKey
        
        // Validate API key is configured
        guard !apiKey.isEmpty else {
            fatalError("Guardian API Key not configured. Please add 'GuardianAPIKey' to Info.plist")
        }
    }
    
    func fetchArticles(page: Int = 1, pageSize: Int = 20) -> AnyPublisher<GuardianResponse, NetworkError> {
        let endpoint = "/search"
        let queryItems = [
            URLQueryItem(name: "api-key", value: apiKey),
            URLQueryItem(name: "show-fields", value: "headline,trailText,bodyText,thumbnail,main,body"),
            URLQueryItem(name: "page-size", value: "\(pageSize)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "order-by", value: "newest")
        ]
        
        var urlComponents = URLComponents(string: baseURL + endpoint)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GuardianResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.serverError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Convenience method for backward compatibility
    func fetchArticles() -> AnyPublisher<[Article], NetworkError> {
        return fetchArticles(page: 1, pageSize: 20)
            .map(\.response.results)
            .eraseToAnyPublisher()
    }
} 
