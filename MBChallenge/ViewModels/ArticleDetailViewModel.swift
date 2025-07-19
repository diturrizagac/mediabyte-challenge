//
//  ArticleDetailViewModel.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import Foundation
import Combine
import UIKit

class ArticleDetailViewModel: ObservableObject {
    @Published var article: Article
    @Published var imageData: Data?
    @Published var isLoadingImage = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(article: Article) {
        self.article = article
        loadImage()
    }
    
    private func loadImage() {
        guard let imageUrlString = article.fields?.imageUrl,
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        
        isLoadingImage = true
        
        URLSession.shared.dataTaskPublisher(for: imageUrl)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoadingImage = false
                },
                receiveValue: { [weak self] data in
                    self?.imageData = data
                }
            )
            .store(in: &cancellables)
    }
    
    var formattedDate: String {
        return DateFormatter.formatGuardianDate(article.webPublicationDate)
    }
    
    var articleTitle: String {
        return article.fields?.headline ?? article.webTitle
    }
    
    var articleBody: String {
        guard let htmlContent = article.fields?.fullBody else {
            return "No content available"
        }
        
        // Convert HTML to plain text
        return convertHTMLToPlainText(htmlContent)
    }
    
    var articleBodyAttributed: NSAttributedString? {
        guard let htmlContent = article.fields?.fullBody else {
            return nil
        }
        
        // Convert HTML to attributed string for rich text display
        return convertHTMLToAttributedString(htmlContent)
    }
    
    private func convertHTMLToPlainText(_ htmlString: String) -> String {
        guard let data = htmlString.data(using: .utf8),
              let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
              ) else {
            return htmlString
        }
        
        return attributedString.string
    }
    
    private func convertHTMLToAttributedString(_ htmlString: String) -> NSAttributedString? {
        guard let data = htmlString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            
            // Apply custom styling
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            let range = NSRange(location: 0, length: mutableAttributedString.length)
            
            // Set font and color
            mutableAttributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.label
            ], range: range)
            
            return mutableAttributedString
        } catch {
            print("Error converting HTML to attributed string: \(error)")
            return nil
        }
    }
} 
