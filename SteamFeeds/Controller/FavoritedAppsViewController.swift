//
//  FavoritedAppsViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import UIKit

class FavoritedAppsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SteamAPIService.getAppList { result in
            switch result {
            case .success(let appListRes):
                print("Get App List Success")
                break
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
                break
            }
        }
    }
    
}
