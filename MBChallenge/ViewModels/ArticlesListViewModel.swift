//
//  ArticlesListViewModel.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import Foundation
import Combine

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case loadingMore
    case error(String)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.loadingMore, .loadingMore):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

class ArticlesListViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var loadingState: LoadingState = .idle
    
    // Pagination properties
    private var currentPage = 1
    var hasMorePages = true
    private let pageSize = 20
    
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchArticles() {
        // Reset pagination for fresh load
        currentPage = 1
        hasMorePages = true
        loadingState = .loading
        
        networkService.fetchArticles(page: currentPage, pageSize: pageSize)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.loadingState = .loaded
                    case .failure(let error):
                        self?.loadingState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.articles = response.response.results
                    self?.hasMorePages = response.response.currentPage < response.response.pages
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshArticles() {
        fetchArticles()
    }
    
    func loadMoreArticles() {
        guard hasMorePages && loadingState != .loadingMore else { return }
        
        currentPage += 1
        loadingState = .loadingMore
        
        networkService.fetchArticles(page: currentPage, pageSize: pageSize)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.loadingState = .loaded
                    case .failure(let error):
                        self?.loadingState = .error(error.localizedDescription)
                        // Revert page number on error
                        self?.currentPage -= 1
                    }
                },
                receiveValue: { [weak self] response in
                    self?.articles.append(contentsOf: response.response.results)
                    self?.hasMorePages = response.response.currentPage < response.response.pages
                }
            )
            .store(in: &cancellables)
    }
    
    var canLoadMore: Bool {
        return hasMorePages && loadingState != .loadingMore
    }
    
    var isLoadingMore: Bool {
        return loadingState == .loadingMore
    }
    
    func formattedDate(for article: Article) -> String {
        return DateFormatter.formatGuardianDate(article.webPublicationDate)
    }
} 