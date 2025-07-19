//
//  ArticleDetailViewModelTests.swift
//  MBChallengeTests
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import XCTest
import Combine
@testable import MBChallenge

class ArticleDetailViewModelTests: XCTestCase {
    
    var viewModel: ArticleDetailViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockArticle: Article!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        
        mockArticle = Article(
            id: "1",
            type: "article",
            sectionId: "news",
            sectionName: "News",
            webPublicationDate: "2023-01-01T12:00:00Z",
            webTitle: "Test Article Title",
            webUrl: "https://example.com",
            apiUrl: "https://api.example.com",
            fields: ArticleFields(
                headline: "Test Headline",
                trailText: "Test trail text",
                bodyText: "Test body text content",
                thumbnail: "https://example.com/image.jpg",
                main: nil,
                body: nil
            ),
            isHosted: false,
            pillarId: "pillar1",
            pillarName: "News"
        )
        
        viewModel = ArticleDetailViewModel(article: mockArticle)
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        mockArticle = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.article.id, "1")
        XCTAssertEqual(viewModel.articleTitle, "Test Headline")
        XCTAssertEqual(viewModel.articleBody, "Test body text content")
        XCTAssertFalse(viewModel.isLoadingImage)
    }
    
    func testFormattedDate() {
        // When
        let formattedDate = viewModel.formattedDate
        
        // Then
        XCTAssertFalse(formattedDate.isEmpty)
        XCTAssertNotEqual(formattedDate, "2023-01-01T12:00:00Z")
        XCTAssertTrue(formattedDate.contains("2023"))
    }
    
    func testArticleTitleWithHeadline() {
        // Given
        let articleWithHeadline = Article(
            id: "1",
            type: "article",
            sectionId: "news",
            sectionName: "News",
            webPublicationDate: "2023-01-01T12:00:00Z",
            webTitle: "Web Title",
            webUrl: "https://example.com",
            apiUrl: "https://api.example.com",
            fields: ArticleFields(
                headline: "Custom Headline",
                trailText: nil,
                bodyText: nil,
                thumbnail: nil,
                main: nil,
                body: nil
            ),
            isHosted: false,
            pillarId: "pillar1",
            pillarName: "News"
        )
        
        let viewModelWithHeadline = ArticleDetailViewModel(article: articleWithHeadline)
        
        // Then
        XCTAssertEqual(viewModelWithHeadline.articleTitle, "Custom Headline")
    }
    
    func testArticleTitleWithoutHeadline() {
        // Given
        let articleWithoutHeadline = Article(
            id: "1",
            type: "article",
            sectionId: "news",
            sectionName: "News",
            webPublicationDate: "2023-01-01T12:00:00Z",
            webTitle: "Web Title",
            webUrl: "https://example.com",
            apiUrl: "https://api.example.com",
            fields: nil,
            isHosted: false,
            pillarId: "pillar1",
            pillarName: "News"
        )
        
        let viewModelWithoutHeadline = ArticleDetailViewModel(article: articleWithoutHeadline)
        
        // Then
        XCTAssertEqual(viewModelWithoutHeadline.articleTitle, "Web Title")
    }
    
    func testArticleBodyWithBodyText() {
        // Given
        let articleWithBody = Article(
            id: "1",
            type: "article",
            sectionId: "news",
            sectionName: "News",
            webPublicationDate: "2023-01-01T12:00:00Z",
            webTitle: "Test Article",
            webUrl: "https://example.com",
            apiUrl: "https://api.example.com",
            fields: ArticleFields(
                headline: nil,
                trailText: nil,
                bodyText: "Full article body content",
                thumbnail: nil,
                main: nil,
                body: nil
            ),
            isHosted: false,
            pillarId: "pillar1",
            pillarName: "News"
        )
        
        let viewModelWithBody = ArticleDetailViewModel(article: articleWithBody)
        
        // Then
        XCTAssertEqual(viewModelWithBody.articleBody, "Full article body content")
    }
    
    func testArticleBodyWithoutContent() {
        // Given
        let articleWithoutBody = Article(
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
        
        let viewModelWithoutBody = ArticleDetailViewModel(article: articleWithoutBody)
        
        // Then
        XCTAssertEqual(viewModelWithoutBody.articleBody, "No content available")
    }
    
    func testImageUrlFromThumbnail() {
        // Given
        let articleWithThumbnail = Article(
            id: "1",
            type: "article",
            sectionId: "news",
            sectionName: "News",
            webPublicationDate: "2023-01-01T12:00:00Z",
            webTitle: "Test Article",
            webUrl: "https://example.com",
            apiUrl: "https://api.example.com",
            fields: ArticleFields(
                headline: nil,
                trailText: nil,
                bodyText: nil,
                thumbnail: "https://example.com/thumbnail.jpg",
                main: "https://example.com/main.jpg",
                body: nil
            ),
            isHosted: false,
            pillarId: "pillar1",
            pillarName: "News"
        )
        
        // Then
        XCTAssertEqual(articleWithThumbnail.fields?.imageUrl, "https://example.com/thumbnail.jpg")
    }
    
    func testImageUrlFromMain() {
        // Given
        let articleWithMain = Article(
            id: "1",
            type: "article",
            sectionId: "news",
            sectionName: "News",
            webPublicationDate: "2023-01-01T12:00:00Z",
            webTitle: "Test Article",
            webUrl: "https://example.com",
            apiUrl: "https://api.example.com",
            fields: ArticleFields(
                headline: nil,
                trailText: nil,
                bodyText: nil,
                thumbnail: nil,
                main: "https://example.com/main.jpg",
                body: nil
            ),
            isHosted: false,
            pillarId: "pillar1",
            pillarName: "News"
        )
        
        // Then
        XCTAssertEqual(articleWithMain.fields?.imageUrl, "https://example.com/main.jpg")
    }
} 