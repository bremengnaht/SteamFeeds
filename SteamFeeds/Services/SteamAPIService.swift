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
        case getNewsForApp(Int32)
        
        var stringValue: String {
            switch self {
            case .getAppList:
                return "\(Endpoints.base)/ISteamApps/GetAppList/v2/"
            case let .getNewsForApp(appid):
                return "\(Endpoints.base)/ISteamNews/GetNewsForApp/v2/?appid=\(appid)"
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
    
    //    static func downloadPhotoFromFlickr(responseGetPhotoList: ResponseGetPhotoList, completion: @escaping (Result<[UIImage], Error>) -> Void) {
    //        let twelveShuffedPhotos: [ResponsePhoto] = Array(responseGetPhotoList.photos.photo.shuffled().prefix(12))
    //        let dispatchGroup = DispatchGroup()
    //        var downloadedImages: [UIImage] = []
    //
    //        for photo in twelveShuffedPhotos {
    //            dispatchGroup.enter()
    //            let url = Endpoints.getPhoto(photo.farm, photo.server, photo.id, photo.secret).url
    //            let task = URLSession.shared.dataTask(with: url) { data, response, error in
    //                if let data = data, let image = UIImage(data: data) {
    //                    downloadedImages.append(image)
    //                } else {
    //                    downloadedImages.append(UIImage(named: "placeholderImage")!)
    //                }
    //                dispatchGroup.leave()
    //            }
    //            task.resume()
    //        }
    //
    //        dispatchGroup.notify(queue: .main) {
    //            completion(.success(downloadedImages))
    //        }
    //    }
}
