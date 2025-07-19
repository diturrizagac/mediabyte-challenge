//
//  ArticlesListViewModelTests.swift
//  MBChallengeTests
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import XCTest
import Combine
@testable import MBChallenge

class ArticlesListViewModelTests: XCTestCase {
    
    var viewModel: ArticlesListViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockNetworkService = MockNetworkService()
        viewModel = ArticlesListViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.articles.count, 0)
        XCTAssertEqual(viewModel.loadingState, .idle)
    }
    
    func testFetchArticlesSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Articles loaded")
        let mockArticles = [
            Article(
                id: "1",
                type: "article",
                sectionId: "news",
                sectionName: "News",
                webPublicationDate: "2023-01-01T12:00:00Z",
                webTitle: "Test Article 1",
                webUrl: "https://example.com/1",
                apiUrl: "https://api.example.com/1",
                fields: nil,
                isHosted: false,
                pillarId: "pillar1",
                pillarName: "News"
            ),
            Article(
                id: "2",
                type: "article",
                sectionId: "sport",
                sectionName: "Sport",
                webPublicationDate: "2023-01-02T12:00:00Z",
                webTitle: "Test Article 2",
                webUrl: "https://example.com/2",
                apiUrl: "https://api.example.com/2",
                fields: nil,
                isHosted: false,
                pillarId: "pillar2",
                pillarName: "Sport"
            )
        ]
        
        mockNetworkService.mockResult = .success(mockArticles)
        
        // When
        viewModel.$articles
            .dropFirst()
            .sink { articles in
                XCTAssertEqual(articles.count, 2)
                XCTAssertEqual(articles[0].webTitle, "Test Article 1")
                XCTAssertEqual(articles[1].webTitle, "Test Article 2")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchArticles()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchArticlesError() {
        // Given
        let expectation = XCTestExpectation(description: "Error state")
        mockNetworkService.mockResult = .failure(.serverError("Network error"))
        
        // When
        viewModel.$loadingState
            .dropFirst()
            .sink { state in
                if case .error(let message) = state {
                    XCTAssertEqual(message, "Network error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchArticles()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadingStateTransitions() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state transitions")
        expectation.expectedFulfillmentCount = 3
        
        var stateTransitions: [LoadingState] = []
        
        // When
        viewModel.$loadingState
            .dropFirst()
            .sink { state in
                stateTransitions.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockNetworkService.mockResult = .success([])
        viewModel.fetchArticles()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateTransitions.count, 3)
        XCTAssertEqual(stateTransitions[0], .loading)
        XCTAssertEqual(stateTransitions[1], .loaded)
    }
    
    func testFormattedDate() {
        // Given
        let article = Article(
            id: "1",
            type: "article",
            sectionId: "news",
            sectionName: "News",
            webPublicationDate: "2023-01-01T12:00:00Z",
            webTitle: "Test Article",
            webUrl: "https://example.com",
            apiUrl: "https://api.example.com",
            fields: nil,
            isHosted: false,
            pillarId: "pillar1",
            pillarName: "News"
        )
        
        // When
        let formattedDate = viewModel.formattedDate(for: article)
        
        // Then
        XCTAssertFalse(formattedDate.isEmpty)
        XCTAssertNotEqual(formattedDate, "2023-01-01T12:00:00Z")
    }
}

// MARK: - Mock Network Service
class MockNetworkService: NetworkService {
    var mockResult: Result<[Article], NetworkError>?
    
    override func fetchArticles() -> AnyPublisher<[Article], NetworkError> {
        guard let mockResult = mockResult else {
            return Fail(error: NetworkError.serverError("No mock result set")).eraseToAnyPublisher()
        }
        
        return mockResult.publisher.eraseToAnyPublisher()
    }
} 