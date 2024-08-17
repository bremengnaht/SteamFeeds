//
//  APIResponseGetAppList.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import Foundation

struct APIResponseGetAppList: Codable {
    let appList: APIResponseApps?
    
    enum CodingKeys: String, CodingKey {
        case appList = "applist"
    }
}

struct APIResponseApps: Codable {
    let apps: [APIResponseApp]?
}

struct APIResponseApp: Codable {
    let appId: Int32
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case appId = "appid"
        case name = "name"
    }
}
