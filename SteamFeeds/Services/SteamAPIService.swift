//
//  SteamAPIService.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import Foundation
import UIKit

class SteamAPIService {
    enum Endpoints {
        static let base = "https://api.steampowered.com"
        
        case getAppList
        case getNewsForApp(Int32,Int,String)
        
        var stringValue: String {
            switch self {
            case .getAppList:
                return "\(Endpoints.base)/ISteamApps/GetAppList/v2/"
            case let .getNewsForApp(appid,count,enddate):
                return "\(Endpoints.base)/ISteamNews/GetNewsForApp/v2/?appid=\(appid)&count=\(count)&enddate=\(enddate)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    static func getAppList(completion: @escaping (Result<APIResponseGetAppList, Error>) -> Void) {
        let url = Endpoints.getAppList.url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(APIResponseGetAppList.self, from: data!)
                completion(.success(responseObject))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    static func getNewsForApp(appId: Int32, endDate: String, completion: @escaping (Result<APIResponseGetNewsForApp, Error>) -> Void) {
        let url = Endpoints.getNewsForApp(appId, 20, endDate).url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(APIResponseGetNewsForApp.self, from: data!)
                completion(.success(responseObject))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
