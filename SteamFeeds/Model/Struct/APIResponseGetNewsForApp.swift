//
//  APIResponseGetNewsForApp.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 18/8/24.
//

import Foundation

struct APIResponseGetNewsForApp: Codable {
    let appNews: APIResponseNews?
    
    enum CodingKeys: String, CodingKey {
        case appNews = "appnews"
    }
}

struct APIResponseNews: Codable {
    let appId: Int32
    let count: Int
    let newsItems: [APIResponseNewsItem]?
    
    enum CodingKeys: String, CodingKey {
        case appId = "appid"
        case count = "count"
        case newsItems = "newsitems"
    }
}

struct APIResponseNewsItem: Codable {
    let appId: Int32
    let author: String
    let contents: String
    let date: Int
    let feedLabel: String
    let gid: String
    let isExternalUrl: Bool
    let title: String
    let url: String
    
    
    enum CodingKeys: String, CodingKey {
        case appId = "appid"
        case author = "author"
        case contents = "contents"
        case date = "date"
        case feedLabel = "feedlabel"
        case gid = "gid"
        case isExternalUrl = "is_external_url"
        case title = "title"
        case url = "url"
    }
}
