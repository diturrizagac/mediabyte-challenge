//
//  Article.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import Foundation

struct Article: Codable {
    let id: String
    let type: String
    let sectionId: String
    let sectionName: String
    let webPublicationDate: String
    let webTitle: String
    let webUrl: String
    let apiUrl: String
    let fields: ArticleFields?
    let isHosted: Bool
    let pillarId: String
    let pillarName: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, sectionId, sectionName, webPublicationDate, webTitle, webUrl, apiUrl, fields, isHosted, pillarId, pillarName
    }
}

struct ArticleFields: Codable {
    let headline: String?
    let trailText: String?
    let bodyText: String?
    let thumbnail: String?
    let main: String?
    let body: String?
    
    var imageUrl: String? {
        return thumbnail ?? main
    }
    
    var fullBody: String? {
        return body ?? bodyText
    }
}

struct GuardianResponse: Codable {
    let response: Response
    
    struct Response: Codable {
        let status: String
        let total: Int
        let startIndex: Int
        let pageSize: Int
        let currentPage: Int
        let pages: Int
        let orderBy: String
        let results: [Article]
    }
} 